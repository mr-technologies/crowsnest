<template>
  <h3 class="componet-title">
    encoder::{{ id }}
  </h3>
  <div class="label">
    <b>Codec:</b> {{ settings.codec }} <br>
    <b>FPS:</b> {{ settings.fps }} <br>
  </div>
  <form
    class="row g-3"
    @submit.prevent="setParams"
  >
    <div class="col-md-2">
      <label for="bitrate"> Bitrate, bps </label>
      <input
        id="bitrate"
        v-model.number="settings.bitrate"
        type="number"
        placeholder="9000000"
        step="100000"
        min="1000000"
        max="20000000"
        required
        :disabled="settingsLoading"
      >
      <br>
      <button
        class="btn btn-info input-group"
        type="submit"
        :class="{ loading: settingsLoading }"
        :disabled="settingsLoading"
      >
        Apply
      </button>
    </div>
  </form>
</template>

<script>
const host_url = window.location.protocol + "//" + window.location.hostname;
const ctrl_iface_url = host_url + "/chains";

export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "Encoder",
  props: {
    chain: {
      type: String,
      default: "chain",
    },
    id: {
      type: String,
      default: "nvenc",
    },
  },

  data() {
    return {
      settingsLoading: false,
      settings: {
        codec: "unknown",
        fps: 60.0,
        bitrate: 9000000
      }
    }
  },

  mounted() {
    this.getParams();
  },

  methods: {
    getParams() {
      const params = {};
      params[this.id] = {
        "params": ["codec", "fps", "bitrate"]
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/get_params", params).then((response) => {
        const data = response.data;
        console.log(data);
        this.settings.fps = data[this.id]?.fps?.toFixed(1);
        this.settings.bitrate = data[this.id]?.bitrate;
        this.settings.codec = data[this.id]?.codec;
      });
    },

    setParams() {
      this.settingsLoading = true;
      const params = {};
      params[this.id] = {
        bitrate: this.settings.bitrate
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/set_params", params).then((response) => {
        console.log(response);
      })
      .finally(() => {
        this.settingsLoading = false;
      });
    }
  }
};
</script>

<style scoped lang="scss">
@import "../assets/styles/main";
</style>
