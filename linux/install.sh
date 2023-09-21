#!/bin/bash
set -eEo pipefail
shopt -s failglob
trap 'echo "${BASH_SOURCE[0]}{${FUNCNAME[0]}}:${LINENO}: Error: command \`${BASH_COMMAND}\` failed with exit code $?"' ERR
cd "$(dirname "$0")"

# Adjust if necessary
IP="127.0.0.1"
INSTALL_ROOT=/opt/mrtech
JOBS_PARAM="-j$(getconf _NPROCESSORS_ONLN || echo 1)"
LIBNICE_VERSION="0.1.17"

sudo mkdir $INSTALL_ROOT
sudo chown $(whoami): $INSTALL_ROOT
export PATH="${INSTALL_ROOT}/bin:${PATH}"

echo "Installing system packages..."
sudo apt update
sudo apt install -y \
    automake \
    cmake \
    curl \
    gengetopt \
    libconfig-dev \
    libcurl4-gnutls-dev \
    libglib2.0-dev \
    libjansson-dev \
    libsrtp2-dev \
    libtool \
    nginx \
    npm \
    ssl-cert
echo "Done."

echo "Updating nodejs..."
npm config set prefix $INSTALL_ROOT
npm install -g n
N_PREFIX=$INSTALL_ROOT n 16
hash -r
echo "Done."

echo "Building janus and its dependencies..."
mkdir janus
pushd janus

curl -LO https://libnice.freedesktop.org/releases/libnice-${LIBNICE_VERSION}.tar.gz
tar -xf libnice-${LIBNICE_VERSION}.tar.gz
pushd libnice-${LIBNICE_VERSION}
./configure --prefix $INSTALL_ROOT
make $JOBS_PARAM
make install
popd

git clone https://github.com/warmcat/libwebsockets.git
mkdir libwebsockets/build
pushd libwebsockets/build
git checkout v4.3-stable
cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX=$INSTALL_ROOT ..
make $JOBS_PARAM
make install
popd

git clone https://github.com/meetecho/janus-gateway.git
pushd janus-gateway
git checkout 0.x
./autogen.sh
./configure --prefix $INSTALL_ROOT PKG_CONFIG_PATH=${INSTALL_ROOT}/lib/pkgconfig LDFLAGS="-L${INSTALL_ROOT}/lib -Wl,-rpath=${INSTALL_ROOT}/lib" CFLAGS=-I${INSTALL_ROOT}/include
make $JOBS_PARAM
make install
make configs
sed "s/@IP@/${IP}/" ../../janus.plugin.streaming.jcfg > ${INSTALL_ROOT}/etc/janus/janus.plugin.streaming.jcfg
popd

popd
echo "Done."

echo "Building web interface..."
pushd ..
npm ci
npm run build
mkdir -p ${INSTALL_ROOT}/var/www/html
cp -RT dist/ ${INSTALL_ROOT}/var/www/html/
popd
echo "Done."

echo "Replacing nginx default server configuration..."
sed "s|@INSTALL_ROOT@|${INSTALL_ROOT}|" nginx.conf | sudo tee /etc/nginx/sites-available/crowsnest > /dev/null
sudo ln -snf ../sites-available/crowsnest /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx
echo "Done."

echo "Success."
echo "To uninstall run: sudo rm -Rf ${INSTALL_ROOT} ${PWD}/janus"
echo "To start WebRTC server do the following steps:"
echo "1). Copy used farsight.json to ${INSTALL_ROOT}/var/www/html/config.json"
echo "NOTE: make sure that IFF/services/rtsp_server/host setting equals to ${IP}"
echo "2). Execute from the working directory of farsight:"
echo "ln -rsnf saved_frames ${INSTALL_ROOT}/var/www/html/"
echo "3). Start previously built farsight sample application:"
echo "./farsight | tee ${INSTALL_ROOT}/var/www/html/log.txt"
echo "4). Start janus from a separate terminal:"
echo "${INSTALL_ROOT}/bin/janus"
echo "5). Now you can navigate to this system's IP address using web browser to see the video stream and change runtime parameters"
echo "NOTE: web server SSL certificate is self-signed by default, which will result in a warning in your web browser, if HTTPS protocol is used."
