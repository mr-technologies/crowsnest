<template>
  <h3 class="componet-title">
    {{ $route.name }}::{{ id }}
  </h3>
  <div class="label">
    <b>Camera:</b> {{ settings.vendor_name + " " + settings.device_name + " (" + settings.serial_number + ")" }} <br>
  </div>
  <form
    class="row g-3"
    @submit.prevent="setParams"
  >
    <div class="col-md-2">
      <h6 class="white-balance-heading label">
        White Balance
      </h6>
      <div class="inline-group">
        <label
          for="white-balance-red"
          class="red"
        > R </label>
        <input
          id="white-balance-red"
          v-model.number="settings.white_balance.red"
          placeholder="1.00"
          type="number"
          step="0.01"
          class="white-balance-red"
          min="0.01"
          required
          :disabled="settingsLoading"
        >
      </div>
      <div class="inline-group">
        <label
          for="white-balance-green"
          class="green"
        > G </label>
        <input
          id="white-balance-green"
          v-model.number="settings.white_balance.green"
          placeholder="1.00"
          type="number"
          step="0.01"
          class="white-balance-green"
          min="0.01"
          required
          :disabled="settingsLoading"
        >
      </div>
      <div class="inline-group">
        <label
          for="white-balance-blue"
          class="blue"
        > B </label>
        <input
          id="white-balance-blue"
          v-model.number="settings.white_balance.blue"
          placeholder="1.00"
          type="number"
          step="0.01"
          class="white-balance-blue"
          min="0.01"
          required
          :disabled="settingsLoading"
        >
      </div>
    </div>
    <div class="col-md-2">
      <div class="mb-3">
        <label for="exposure"> Exposure, μs </label>
        <input
          id="exposure"
          v-model.number="settings.exposure"
          type="number"
          placeholder="10000"
          step="1"
          min="1"
          required
          :disabled="settingsLoading"
        >
      </div>
      <div class="mb-3">
        <label for="gain"> Gain, dB </label>
        <input
          id="gain"
          v-model.number="settings.gain"
          placeholder="0.0"
          type="number"
          step="0.1"
          required
          :disabled="settingsLoading"
        >
      </div>
    </div>
    <div class="col-md-1">
      <button
        class="btn btn-info input-group"
        type="submit"
        :class="{ loading: settingsLoading }"
        :disabled="settingsLoading"
      >
        Apply
      </button>
    </div>
    <div class="col-md-1">
      <button
        class="btn btn-success input-group"
        :class="{ loading: settingsLoading }"
        :disabled="settingsLoading"
        @click="getParams"
      >
        Refresh
      </button>
    </div>
  </form>
</template>

<script>
// import config from "@/config.json";

const host_url = window.location.protocol + "//" + window.location.hostname;
const ctrl_iface_url = host_url + "/chains";

export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "Camera",
  props: {
    chain: {
      type: String,
      default: "chain",
    },
    id: {
      type: String,
      default: "camera1",
    },
  },

  data() {
    return {
      settingsLoading: false,
      settings: {
        exposure: 10000,
        gain: 0.0,
        white_balance: {
          red: 1.0,
          green: 1.0,
          blue: 1.0,
        },
        vendor_name: "",
        device_name: "",
        serial_number: "<SN>"
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
        "params": ["exposure", "gain", "wb", "vendor_name", "device_name", "serial_number"]
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/get_params", params).then((response) => {
        const data = response.data;
        console.log(data);
        this.settings.gain = data[this.id]?.gain?.toFixed(2);
        this.settings.exposure = data[this.id]?.exposure;
        this.settings.white_balance.red = data[this.id]?.wb?.r?.toFixed(2);
        this.settings.white_balance.green = (
            (data[this.id]?.wb?.g1 + data[this.id]?.wb?.g2) /
            2
        ).toFixed(2);
        this.settings.white_balance.blue = data[this.id]?.wb?.b?.toFixed(2);
        this.settings.vendor_name = data[this.id]?.vendor_name;
        this.settings.device_name = data[this.id]?.device_name;
        this.settings.serial_number = data[this.id]?.serial_number;
      });
    },

    setParams() {
      this.settingsLoading = true;
      const params = {};
      params[this.id] = {
        exposure: this.settings.exposure,
        gain: parseFloat(this.settings.gain),
        wb: {
          r: parseFloat(this.settings.white_balance.red),
          g: parseFloat(this.settings.white_balance.green),
          b: parseFloat(this.settings.white_balance.blue),
        },
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
