import { createRouter, createWebHashHistory } from "vue-router";
import Camera from "../views/Camera.vue";
import DngWriter from "../views/DngWriter.vue";
import CudaProcessor from "../views/CudaProcessor.vue";
import AwbAec from "../views/AwbAec.vue";
import Encoder from "../views/Encoder.vue";
import RtspStream from "../views/RtspStream.vue";

const routes = [
  {
    path: "/:chain/xicamera/:id",
    name: "xicamera",
    component: Camera,
    props: true,
  },
  {
    path: "/:chain/genicam/:id",
    name: "genicam",
    component: Camera,
    props: true,
  },
  {
    path: "/:chain/dng_writer/:id",
    name: "dng_writer",
    component: DngWriter,
    props: true,
  },
  {
    path: "/:chain/cuda_processor/:id",
    name: "cuda_processor",
    component: CudaProcessor,
    props: true,
  },
  {
    path: "/:chain/awb_aec/:id",
    name: "awb_aec",
    component: AwbAec,
    props: true,
  },
  {
    path: "/:chain/encoder/:id",
    name: "encoder",
    component: Encoder,
    props: true,
  },
  {
    path: "/:chain/rtsp_stream/:id",
    name: "rtsp_stream",
    component: RtspStream,
    props: true,
  },
];

const router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
