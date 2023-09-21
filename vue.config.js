const { defineConfig } = require('@vue/cli-service')
const webpack = require("webpack")
module.exports = defineConfig({
  transpileDependencies: true,
  configureWebpack: {
    plugins: [
      new webpack.ProvidePlugin({ adapter: ["webrtc-adapter", "default"] }),
    ],
    module: {
      rules: [
        {
          test: require.resolve("janus-gateway"),
          loader: "exports-loader",
          options: {
            exports: "Janus",
          },
        },
      ],
    },
  },
})
