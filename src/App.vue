<template>
  <div class="container-fluid">
    <div class="mb-2 border-bottom page-header">
      <img
        src="sdk-logo-50.png"
        class="page-logo d-inline"
        alt="MRTech IFF SDK"
      >
      <h4 class="d-inline page-title">
        Crow's Nest: MRTech IFF SDK web interface sample
      </h4>
    </div>
    <ul
      id="myTab"
      class="nav nav-tabs"
      role="tablist"
    >
      <li
        class="nav-item"
        role="presentation"
      >
        <button
          id="elements-tab"
          class="nav-link active"
          data-bs-toggle="tab"
          data-bs-target="#elements"
          type="button"
          role="tab"
          aria-controls="elements"
          aria-selected="true"
        >
          Elements
        </button>
      </li>
      <li
        class="nav-item"
        role="presentation"
      >
        <button
          id="config-tab"
          class="nav-link"
          data-bs-toggle="tab"
          data-bs-target="#config"
          type="button"
          role="tab"
          aria-controls="config"
          aria-selected="false"
        >
          Config File
        </button>
      </li>
      <li
        class="nav-item"
        role="presentation"
      >
        <button
          id="log-tab"
          class="nav-link"
          data-bs-toggle="tab"
          data-bs-target="#log"
          type="button"
          role="tab"
          aria-controls="log"
          aria-selected="false"
        >
          App Log
        </button>
      </li>
      <li
        class="nav-item"
        role="presentation"
      >
        <button
          id="about-tab"
          class="nav-link"
          data-bs-toggle="tab"
          data-bs-target="#about"
          type="button"
          role="tab"
          aria-controls="about"
          aria-selected="false"
        >
          About
        </button>
      </li>
    </ul>
    <div
      id="myTabContent"
      class="tab-content"
    >
      <div
        id="elements"
        class="tab-pane fade show active"
        role="tabpanel"
        aria-labelledby="elements-tab"
      >
        <div class="row">
          <div class="col-2">
            <nav>
              <template v-if="chain">
                <router-link
                  v-for="element in chain.elements"
                  :key="element.id"
                  class="item"
                  :to="{ name: element.type, params: { chain: chain.id, id: element.id } }"
                >
                  <div class="title">
                    {{ element.type + "::" + element.id }}
                  </div>
                </router-link>
              </template>
            </nav>
          </div>
          <div class="col-10">
            <div class="chain">
              <section class="section video">
                <video
                  id="remotevideo"
                  ref="remotevideo"
                  controls
                  playsinline
                />
                <br>
                <button
                  class="btn btn-info"
                  :disabled="hasremotevideo"
                  @click="startStream"
                >
                  Start
                </button>
                <button
                  class="btn btn-info"
                  :disabled="!hasremotevideo"
                  @click="stopStream"
                >
                  Stop
                </button>
              </section>
              <section class="section settings">
                <router-view v-slot="{ Component, route }">
                  <transition name="fade">
                    <component
                      :is="Component"
                      :key="route.path"
                      class="main"
                    />
                  </transition>
                </router-view>
              </section>
            </div>
          </div>
        </div>
      </div>
      <div
        id="config"
        class="tab-pane fade"
        role="tabpanel"
        aria-labelledby="config-tab"
      >
        <pre id="json_config">{{ app_config }}</pre>
      </div>
      <div
        id="log"
        class="tab-pane fade"
        role="tabpanel"
        aria-labelledby="log-tab"
      >
        <pre id="app_log">{{ app_log }}</pre>
      </div>
      <div
        id="about"
        class="tab-pane fade"
        role="tabpanel"
        aria-labelledby="about-tab"
      >
        <p class="h5">
          About
        </p>
        <p class="h6">
          Crow's Nest
        </p>
        <p>
          This sample web interface shows how MRTech IFF SDK can be used to stream video to a client browser.<br>
          It also demonstrates IFF SDK capabilities to remotely control acquisition and processing parameters at
          runtime.<br>
          The video is streamed over WebRTC via Janus gateway, so the video stream is compatible with most browsers.
        </p>
        <p class="h6">
          Usage how-to
        </p>
        <p>The following functionality and information are available on four web interface tabs.</p>
        <b>Elements</b> tab:
        <ol>
          <li>View the video stream and control the viewing window: in a built-in frame, in full screen or picture-in-picture mode.</li>
          <li>Start/stop video stream from the camera.</li>
          <li>
            Set the exposure, gain and white balance on <b>xicamera::cam</b> or <b>genicam::cam</b> menu item:
            <ul>
              <li>Press <b>Apply</b> button to save and use the entered values,</li>
              <li>Press <b>Refresh</b> button to get currently used values.</li>
            </ul>
            Note: Changing the exposure and white balance is possible when <b>awb_aec::autoctrl</b> parameters
            (see below) are set to <b>Auto-exposure: OFF</b> and <b>Auto white balance: OFF</b> respectively.
          </li>
          <li>Enable/disable auto-exposure and auto white balance in <b>awb_aec::autoctrl</b> menu item.</li>
          <li>Save and download single raw (DNG) frame from the camera using <b>dng_writer::writer</b> menu item.</li>
          <li><b>cuda_processor::gpuproc</b> menu item shows information about the used processing elements running on NVIDIA GPU.</li>
          <li>Use <b>encoder::nvenc</b> menu item to set the desired encoder bitrate.</li>
        </ol>
        <b>Config File</b> tab:
        <ul>
          <li>Shows the configuration file contents for the application in use.</li>
        </ul>
        <b>App log</b> tab:
        <ul>
          <li>Shows the last 30 lines of the application log file updated every 5 seconds.</li>
        </ul>
        <b>About</b> tab:
        <ul>
          <li>This text.</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
import Camera from "@/views/Camera";
import DngWriter from "@/views/DngWriter";
import CudaProcessor from "@/views/CudaProcessor";
import AwbAec from "@/views/AwbAec";
import Encoder from "@/views/Encoder";
import RtspStream from "@/views/RtspStream";

import stripJsonComments from 'strip-json-comments';
import {Janus} from 'janus-gateway';
import config from "@/config.json";

const opaqueId = "crowsnest-" + Janus.randomString(12);
const protocol = (window.location.protocol === 'http:') ? "ws://" : "wss://";
const janus_url = protocol + window.location.hostname + config.janus_rel_url;
const host_url = window.location.protocol + "//" + window.location.hostname;
const config_url = host_url + config.config_rel_url;
const log_url = host_url + config.log_rel_url;

const average_line_length = 100;
const num_lines_to_fetch = 31;
const margin_for_error = 0.2;
const bytes_to_fetch_from_log = average_line_length * num_lines_to_fetch * (1 + margin_for_error);

export default
{
  components: {
    Camera,
    DngWriter,
    CudaProcessor,
    AwbAec,
    Encoder,
    RtspStream,
  },

  data() {
    return {
      timer: null,
      janus: null,
      streaming: null,
      hasremotevideo: false,
      error: null,
      status: null,
      streamList: {
        selected: null,
        options: []
      },
      app_config: "",
      app_log: "",
      control_interface_url: null,
      chain: {
        id: "",
        elements: []
      }
    }
  },

  mounted() {
    this.axios.get(config_url).then((response) => {
      console.log(response.data);
      if(typeof(response.data) === 'string') {
        response.data = JSON.parse(stripJsonComments(response.data));
      }
      this.app_config = JSON.stringify(response.data, undefined, 4);
      this.control_interface_url = host_url + "/chains";
      let chain = response.data.chains[0];
      this.chain.id = chain.id;
      chain.elements.forEach((element) => {
        let el = {id: element.id, type: element.type};
        if(this.$router.hasRoute(el.type)) {
          this.chain.elements.push(el);
        }
      });
      console.log(this.chain);
    });

    this.getLog();
    this.timer = setInterval(() => {
      this.getLog();
    }, 5000);

    Janus.init({
      debug: "all", callback: () => {
        this.janus = new Janus(
        {
          server: janus_url,
          success: () => {
            this.attachToPlugin()
          },
          error: (error) => {
            this.onError('Failed to connect to janus server', error)
          },
          destroyed: () => {
            window.location.reload()
          }
        });
      }
    });
  },

  beforeUmount() {
    clearInterval(this.timer)
  },

  methods: {
    attachToPlugin() {
      // Attach to Streaming plugin
      this.janus.attach(
          {
            plugin: "janus.plugin.streaming",
            opaqueId: opaqueId,
            success: (pluginHandle) => {
              this.streaming = pluginHandle;
              Janus.debug("Plugin attached! (" + this.streaming.getPlugin() + ", id=" + this.streaming.getId() + ")");
              this.updateStreamsList();
            },
            error: (error) => {
              this.onError('Error attaching plugin... ', error);
            },
            iceState: (state) => {
              Janus.log("ICE state changed to " + state);
            },
            webrtcState: (on) => {
              Janus.log("Janus says our WebRTC PeerConnection is " + (on ? "up" : "down") + " now");
            },
            onmessage: (msg, jsep) => {
              this.onJanusMessage(msg, jsep);
            },
            onremotestream: (stream) => {
              this.onJanusRemoteStream(stream);
            },
            oncleanup: () => {
              this.onCleanup();
            }
          })
    },

    updateStreamsList() {
      Janus.log("Getting streams list from server");
      this.streaming.send({
        message: {request: "list"},
        success: (result) => {
          if (!result) {
            this.onError("Got no response to our query for available streams");
            return;
          }
          this.streamList.options = result.list;
          if (result.list.length) {
            this.streamList.selected = this.streamList.options[0].id;
          }
        }
      });
    },

    onJanusMessage(msg, jsep) {
      Janus.debug(" ::: Got a message :::", msg);
      if (msg && msg.result) {
        const result = msg.result;
        this.status = result.status;
        if (result.status === 'stopped')
          this.stopStream();
      } else if (msg && msg.error) {
        this.onError(msg.error);
        this.stopStream();
        return;
      }
      if (jsep) {
        Janus.debug("Handling SDP as well...", jsep);
        var stereo = (jsep.sdp.indexOf("stereo=1") !== -1);
        // Offer from the plugin, let's answer
        this.streaming.createAnswer(
            {
              jsep: jsep,
              // We want recvonly audio/video and, if negotiated, datachannels
              media: {audioSend: false, videoSend: false, data: true},
              customizeSdp: (jsep) => {
                if (stereo && jsep.sdp.indexOf("stereo=1") === -1) {
                  // Make sure that our offer contains stereo too
                  jsep.sdp = jsep.sdp.replace("useinbandfec=1", "useinbandfec=1;stereo=1");
                }
              },
              success: (jsep) => {
                Janus.debug("Got SDP!", jsep);
                var body = {request: "start"};
                this.streaming.send({message: body, jsep: jsep});
              },
              error: (error) => {
                this.onError("WebRTC error:", error);
              }
            });
      }
    },

    onJanusRemoteStream(stream) {
      Janus.debug("::: Got a remote stream :::", stream);
      Janus.attachMediaStream(this.$refs.remotevideo, stream);
      this.$refs.remotevideo.play().catch((error) => { console.log(error); }); //catch to silence error on the browser console
      this.$refs.remotevideo.volume = 1;
      var videoTracks = stream.getVideoTracks();
      this.hasremotevideo = !(!videoTracks || videoTracks.length === 0);
    },

    onCleanup() {
      this.status = null;
      this.error = null;
      this.hasremotevideo = false;
    },

    onError(message, error = '') {
      Janus.error(message, error);
      this.error = message + error;
    },

    startCam() {
      const requestObject = new XMLHttpRequest(); // object of request
      requestObject.onload = function() {
        console.log(this.responseText);
      }
      requestObject.open("POST", this.control_interface_url + "/" + this.chain.id + "/execute");
      requestObject.send("{\"cam\":{\"command\":\"start\"}}"); // data to send in request
    },

    stopCam() {
      const requestObject = new XMLHttpRequest(); // object of request
      requestObject.onload = function() {
        console.log(this.responseText);
      }
      requestObject.open("POST", this.control_interface_url + "/" + this.chain.id + "/execute");
      requestObject.send("{\"cam\":{\"command\":\"stop\"}}"); // data to send in request
    },

    startStream() {
      this.startCam();
      Janus.log("Selected video id #" + this.streamList.selected);
      var body = {request: "watch", id: parseInt(this.streamList.selected) || this.streamList.selected};
      this.streaming.send({message: body});
    },

    stopStream() {
      this.streaming.send({message: {request: "stop"}});
      this.streaming.hangup();
      this.onCleanup();
      this.stopCam();
    },

    getLog() {
      let range = "bytes=-" + bytes_to_fetch_from_log;
      console.log('Fetching last ' + bytes_to_fetch_from_log + ' bytes from log');
      this.axios.get(log_url, {
        headers: {
          Range: range
        }
      }).then((response) => {
        let lines = response.data.split("\n");
        lines = lines.slice(num_lines_to_fetch * -1);
        this.app_log = "";
        lines.forEach((line) => {
          this.app_log += (line + "\n");
        });
        console.log('Got ' + num_lines_to_fetch + ' lines of log');
      });
    },
  }
}
</script>

<style lang="scss">
@import "@/assets/styles/main.scss";

video {
  width: 480px;
  height: 360px;
  background-color: black;
}

nav {
  border-right: 1px solid $gray-light;
  display: flex;
  flex-flow: column;
  overflow: auto;
  padding: 1rem 0;

  .page-logo {
    width: 46px;
    height: 46px;
    max-width: 46px;
    max-height: 46px;
  }

  .item {
    padding: 1rem;
    padding-left: 2rem;
    padding-right: 2rem;
    color: $gray-darkest;
    transition: all 0.1s ease-in-out;
    .small {
      font-size: 0.7rem;
      margin-top: 0.25rem;
      color: rgba($text-color, 0.5);
      .ip {
        font-family: $font-family-monospace;
      }
    }

    &.all {
      margin-top: 2rem;
    }
    &:hover,
    &:focus {
      background-color: rgba($blue, 0.08);
      cursor: pointer;
      color: $gray-darkest;
    }
    &.router-link-exact-active {
      background-color: rgba($blue, 0.1);
      color: darken($blue, 15);
      .small {
        color: darken($blue, 15);
        opacity: 0.9;
      }
    }
  }
}

.chain {
  position: relative;

  .notice {
    transition: all 0.15s ease;
    width: max-content;
    margin-top: 2rem;
    margin-left: 3rem;
    text-align: center;
    padding: 0.5rem 1rem;
    border-radius: 8px;
    box-shadow: inset 0 0 0 2px rgba($orange, 0.5);
    background-color: rgba($orange, 0.05);
    color: $orange;
  }
}

.title {
  //font-weight: 500;
  font-size: 1.1rem;
  padding-bottom: 1rem;
  margin-bottom: 1rem;
}

.componet-title {
  //font-weight: 500;
  font-size: 1.1rem;
  padding-bottom: 1rem;
  margin-bottom: 1rem;
  color: $green;
}

section {
  padding: 2rem 2rem 2rem 3rem;

  .col {
    margin-right: 2rem;
    width: 200px;
  }

  .form {
    display: flex;
    align-items: stretch;
    .col {
      margin-right: 2rem;
      width: 200px;
    }
    .btn {
      align-self: flex-end;
      max-width: 150px;
    }
  }
}

.page-header {
  color: $blue;
  background-color: $gray-darker;
}

.page-title {
  padding-left: 4px;
}

.expogain {
  display: flex;
  flex-flow: column;
  justify-content: space-between;
}

.video {
  padding-bottom: 4rem;
}

.inline-group {
  position: relative;
  label {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    left: -1.05rem;
    color: $gray;
    font-size: 0.65rem;
    font-weight: bold;
    &.red {
      color: $red;
    }
    &.green {
      color: $green;
    }
    &.blue {
      color: $blue;
    }
  }
  input {
    //padding-left: 1.75rem;
  }
}

.settings {
  box-shadow: 3rem -1px 0 $gray-light;
}

</style>

<style lang="scss">
@import "@/assets/styles/main.scss";

.fade-enter-active {
  transition: background-color 2s ease;
}
.fade-leave-active {
}
.fade-enter-from {
  background-color: $yellow-highlight;
  opacity: 0;
}
.fade-enter-to {
  // background-color: $gray-silver;
}
</style>
