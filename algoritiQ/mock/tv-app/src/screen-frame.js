import { applyDocumentLocale, t } from "./tv-l10n.js";

/** @param {Record<string, unknown>} cfg */
function applyPreview(cfg) {
  const html = document.documentElement;
  if (cfg.textScale != null) {
    document.body.style.zoom = String(cfg.textScale);
  }
  if (cfg.safeArea != null) {
    html.dataset.safeArea = cfg.safeArea ? "on" : "off";
  }
}

window.addEventListener("message", (event) => {
  if (event.data?.type !== "mock-preview") return;
  applyPreview(event.data);
});

applyDocumentLocale();
window.parent.postMessage({ type: "mock-screen-ready" }, "*");

export { t };
