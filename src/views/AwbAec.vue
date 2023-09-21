<template>
  <h3 class="componet-title">
    awb_aec::{{ id }}
  </h3>
  <div class="input-group col">
    <label for="aec"> Auto-exposure: {{ settings.aec_enabled?"ON":"OFF" }} </label>
    <button
      id="aec"
      class="btn col"
      :disabled="settingsLoading"
      :class="{ loading: settingsLoading, btnoff: settings.aec_enabled, btnon: !settings.aec_enabled }"
      @click="toggleAEC"
    >
      {{ settings.aec_enabled?"OFF":"ON" }}
    </button>
  </div>
  <br>
  <div class="input-group col">
    <label for="awb"> Auto White Balance: {{ settings.awb_enabled?"ON":"OFF" }} </label>
    <button
      id="awb"
      class="btn col"
      :disabled="settingsLoading"
      :class="{ loading: settingsLoading, btnoff: settings.awb_enabled, btnon: !settings.awb_enabled }"
      @click="toggleAWB"
    >
      {{ settings.awb_enabled?"OFF":"ON" }}
    </button>
  </div>
</template>

<script>
const host_url = window.location.protocol + "//" + window.location.hostname;
const ctrl_iface_url = host_url + "/chains";

export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "AwbAec",
  props: {
    chain: {
      type: String,
      default: "chain",
    },
    id: {
      type: String,
      default: "autoctrl",
    },
  },

  data() {
    return {
      settingsLoading: false,
      settings: {
        aec_enabled: true,
        awb_enabled: true
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
        "params": ["aec_enabled", "awb_enabled"]
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/get_params", params).then((response) => {
        const data = response.data;
        console.log(data);
        this.settings.aec_enabled = data[this.id]?.aec_enabled;
        this.settings.awb_enabled = data[this.id]?.awb_enabled;
      });
    },

    setParams() {
      this.settingsLoading = true;
      const params = {};
      params[this.id] = {
        aec_enabled: this.settings.aec_enabled,
        awb_enabled: this.settings.awb_enabled
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/set_params", params).then((response) => {
        console.log(response);
      })
      .finally(() => {
        this.settingsLoading = false;
      });
    },

    toggleAEC() {
      this.settings.aec_enabled = !this.settings.aec_enabled;
      this.setParams();
    },

    toggleAWB() {
      this.settings.awb_enabled = !this.settings.awb_enabled;
      this.setParams();
    }
  }
};
</script>

<style scoped lang="scss">
@import "../assets/styles/main";
</style>
