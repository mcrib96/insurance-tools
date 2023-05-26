import { createRouter, createWebHistory } from "vue-router";
import PageHome from "./pages/PageHome.vue";
import PageAbout from "./pages/PageAbout.vue";
import PageAcordForms from "./pages/PageAcordForms.vue";
import PageAcordEOI27 from "./pages/PageAcordEOI27.vue";
import PageAcordEOI25 from "./pages/PageAcordEOI25.vue";

const routes = [
  {
    path: "/",
    redirect: "/insurance/home",
  },
  {
    path: "/insurance/home",
    name: "Home",
    component: PageHome,
  },
  {
    path: "/insurance/about",
    name: "About",
    component: PageAbout,
  },
  {
    path: "/insurance/forms",
    name: "Forms",
    component: PageAcordForms,
  },
  {
    path: "/insurance/eoi27",
    name: "EOI27",
    component: PageAcordEOI27,
  },
  {
    path: "/insurance/eoi25",
    name: "COI25",
    component: PageAcordEOI25,
  },
];
const router = createRouter({
  history: createWebHistory(),
  routes: routes,
});

export default router;
