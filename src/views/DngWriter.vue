<template>
  <h3 class="componet-title">
    dng_writer::{{ id }}
  </h3>
  <form
    class="row"
    @submit.prevent="startWriting"
  >
    <div class="col-2">
      <label for="count"> Number of frames </label>
      <input
        id="count"
        v-model.number="recording.count"
        class="mb-3"
        type="number"
        min="1"
        required
        :disabled="recordingLoading"
      >
      <button
        class="btn btn-success input-group mb-3"
        type="submit"
        :class="{ loading: recordingLoading }"
        :disabled="recordingLoading"
      >
        Save frames
      </button>
      <template v-if="recording.frameSaved">
        <a
          :href="recording.frameLink"
          rel="noreferrer noopener"
          target="_blank"
        >
          Download Frames
        </a>
      </template>
    </div>
  </form>
</template>

<script>
const host_url = window.location.protocol + "//" + window.location.hostname;
const ctrl_iface_url = host_url + "/chains";

export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "DngWriter",
  props: {
    chain: {
      type: String,
      default: "chain",
    },
    id: {
      type: String,
      default: "writer",
    },
  },

  data() {
    return {
      recordingLoading: false,
      recording: {
        count: 1,
        subdirectory: "",
        frameSaved: false,
        frameLink: ""
      },
    };
  },

  methods: {
    startWriting() {
      let cur_ts = new Date();
      this.recordingLoading = true;
      this.recording.frameSaved = false;
      this.recording.subdirectory = cur_ts.toISOString();
      this.recording.frameLink = "saved_frames/" + this.recording.subdirectory + "/"
      const command = {};
      command[this.id] = {
        command: "on",
        args: {
          frames_count: this.recording.count,
          subdirectory: this.recording.subdirectory
        }
      };
      this.axios.post(ctrl_iface_url + "/" + this.chain + "/execute", command).then((response) => {
        console.log(response);
      })
      .finally(() => {
        this.recordingLoading = false;
        this.recording.frameSaved = true;
      });
    }
  }
};
</script>

<style scoped lang="scss">
@import "../assets/styles/main";
</style>
