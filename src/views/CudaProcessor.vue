<template>
  <h3 class="componet-title">
    cuda_processor::{{ id }}
  </h3>
  <div class="label">
    <b>This filter uses the following elements to process incoming images on NVIDIA GPU:</b>
  </div>
  <ul class="list-unstyled">
    <li>• Import images</li>
    <li>• Black level</li>
    <li>• White balance</li>
    <li>• Debayer</li>
    <li>• Color correction</li>
    <li>• Gamma correction</li>
    <li>• Histogram</li>
    <li>• Export images</li>
  </ul>
</template>

<script>
export default {
  // eslint-disable-next-line vue/multi-word-component-names
  name: "CudaProcessor",
  props: {
    chain: {
      type: String,
      default: "chain",
    },
    id: {
      type: String,
      default: "gpuproc",
    },
  },
};
</script>

<style scoped lang="scss">
@import "../assets/styles/main";
</style>
