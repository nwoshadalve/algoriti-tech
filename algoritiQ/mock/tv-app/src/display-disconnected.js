import { renderIdentity } from "./tv-display.js";
import { t } from "./tv-l10n.js";

const root = document.querySelector("[data-tv-display-root]");
renderIdentity(root);

function updateBannerTime() {
  const el = document.querySelector("[data-l10n-time]");
  if (!el) return;
  const time = el.getAttribute("data-l10n-time") ?? "১০:৪২";
  el.textContent = t("displayLastUpdate", { time });
}

updateBannerTime();
