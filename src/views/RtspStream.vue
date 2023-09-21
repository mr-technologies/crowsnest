<template>
  <h3 class="componet-title">
    rtsp_stream::{{ id }}
  </h3>
  <div class="label">
    <b>Relative URI:</b> {{ settings.relative_uri }} <br>
  </div>
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
      default: "rtsp_stream",
    },
  },

  data() {
    return {
      settingsLoading: false,
      settings: {
        relative_uri: "unknown",
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
        "params": ["relative_uri"]
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/get_params", params).then((response) => {
        const data = response.data;
        console.log(data);
        this.settings.relative_uri = data[this.id]?.relative_uri;
      });
    },
  }
};
</script>

<style scoped lang="scss">
@import "../assets/styles/main";
</style>
