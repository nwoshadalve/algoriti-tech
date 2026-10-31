import { readdirSync } from "node:fs";
import { resolve } from "node:path";
import { defineConfig } from "vite";

const root = import.meta.dirname;
const screensDir = resolve(root, "screens");
const screenHtml = readdirSync(screensDir).filter((f) => f.endsWith(".html"));

/** @type {Record<string, string>} */
const input = { preview: resolve(root, "index.html") };
for (const file of screenHtml) {
  const id = file.replace(/\.html$/, "");
  input[id] = resolve(screensDir, file);
}

export default defineConfig({
  root: ".",
  server: {
    port: 5173,
    open: "/index.html",
  },
  build: {
    rollupOptions: { input },
  },
});
