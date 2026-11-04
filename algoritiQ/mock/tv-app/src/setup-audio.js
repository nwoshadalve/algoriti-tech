import { formatSerial, t } from "./tv-l10n.js";

const volume = document.getElementById("volume");
const volumeValue = document.getElementById("volume-value");
const testBtn = document.getElementById("test-audio");
const status = document.getElementById("audio-status");

volume?.addEventListener("input", () => {
  if (!volumeValue || !volume) return;
  volumeValue.textContent = `${formatSerial(Number(volume.value))}%`;
  if (!status) return;
  const ok = Number(volume.value) >= 25;
  status.classList.toggle("tv-status-pill--warn", !ok);
  status.textContent = t(ok ? "audioReady" : "audioNotReady");
});

testBtn?.addEventListener("click", () => {
  testBtn.disabled = true;
  window.setTimeout(() => {
    testBtn.disabled = false;
    testBtn.textContent = t("audioTest");
  }, 1200);
});

if (volumeValue && volume) {
  volumeValue.textContent = `${formatSerial(Number(volume.value))}%`;
}
