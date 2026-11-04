import "./shell.css";
import { screens } from "./screens-list.js";

const STORAGE_KEY = "algoritiq-mock-tv";

const defaultState = {
  screen: "display-live",
  viewport: "hd",
  textScale: "1",
  safeArea: true,
};

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { ...defaultState };
    return { ...defaultState, ...JSON.parse(raw) };
  } catch {
    return { ...defaultState };
  }
}

function saveState(state) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

/** @param {typeof defaultState} state */
function previewPayload(state) {
  return {
    type: "mock-preview",
    textScale: Number(state.textScale),
    safeArea: state.safeArea,
  };
}

let state = loadState();
/** @type {HTMLIFrameElement | null} */
let frame = null;

function mount() {
  const root = document.getElementById("app");
  root.innerHTML = `
    <div class="mock-shell mock-shell--minimal">
      <aside class="mock-controls" aria-label="Preview controls (not part of TV UI)">
        <h1 class="mock-controls__title">AlgoritiQ TV mock</h1>
        <p class="mock-controls__hint">Developer picker only. Open <code>/screens/display-live.html</code> full-screen on the TV for true 100% scaling (any resolution). Layout: <strong>left</strong> doctor/chamber, <strong>right</strong> announcement + queue — no scrolling.</p>
        <label class="mock-field">
          <span>Screen</span>
          <select id="screen-select"></select>
        </label>
        <label class="mock-field">
          <span>Viewport</span>
          <select id="viewport-select">
            <option value="hd">HD TV — 1366 × 768</option>
            <option value="720p">720p — 1280 × 720</option>
          </select>
        </label>
        <label class="mock-field">
          <span>Text size</span>
          <select id="text-scale-select">
            <option value="1">100%</option>
            <option value="1.15">115%</option>
            <option value="1.3">130%</option>
          </select>
        </label>
        <label class="mock-field">
          <input type="checkbox" id="safe-area" />
          TV safe-area padding (overscan)
        </label>
      </aside>
      <div class="mock-preview-wrap">
        <div id="device" class="device">
          <div class="device-bezel">
            <div class="device-screen">
              <iframe id="screen-frame" title="TV screen preview"></iframe>
            </div>
          </div>
        </div>
      </div>
    </div>
  `;

  frame = document.getElementById("screen-frame");

  const select = document.getElementById("screen-select");
  for (const s of screens) {
    const opt = document.createElement("option");
    opt.value = s.id;
    opt.textContent = s.label;
    select.appendChild(opt);
  }
  select.value = state.screen;

  document.getElementById("viewport-select").value = state.viewport;
  document.getElementById("text-scale-select").value = state.textScale;
  document.getElementById("safe-area").checked = state.safeArea;

  select.addEventListener("change", () => {
    state.screen = select.value;
    saveState(state);
    loadScreen();
  });

  document.getElementById("viewport-select").addEventListener("change", (e) => {
    state.viewport = e.target.value;
    saveState(state);
    applyDeviceChrome();
    pushPreview();
  });

  document.getElementById("text-scale-select").addEventListener("change", (e) => {
    state.textScale = e.target.value;
    saveState(state);
    pushPreview();
  });

  document.getElementById("safe-area").addEventListener("change", (e) => {
    state.safeArea = e.target.checked;
    saveState(state);
    pushPreview();
  });

  window.addEventListener("message", (event) => {
    if (event.data?.type === "mock-screen-ready") pushPreview();
  });

  applyDeviceChrome();
  loadScreen();
}

function screenFile(id) {
  return screens.find((s) => s.id === id)?.file ?? "display-live.html";
}

function loadScreen() {
  if (!frame) return;
  frame.src = `/screens/${screenFile(state.screen)}`;
}

function applyDeviceChrome() {
  const device = document.getElementById("device");
  device.classList.toggle("device--viewport-720p", state.viewport === "720p");
}

function pushPreview() {
  frame?.contentWindow?.postMessage(previewPayload(state), "*");
}

mount();
