import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import vuetify from "vite-plugin-vuetify";
import { nodePolyfills } from "vite-plugin-node-polyfills";

// https://vitejs.dev/config/
export default defineConfig({
  base: "/insurance",
  define: {
    "process.env": {},
  },
  plugins: [
    vue(),
    vuetify({ autoImport: true }),
    nodePolyfills({ protocolImports: true }),
  ],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
    extensions: [".js", ".json", ".mjs", ".ts", ".vue"],
  },
});
