import "./shell.css";
import { screens } from "./screens-list.js";

const STORAGE_KEY = "algoritiq-mock-app";

const defaultState = {
  screen: "activation",
  theme: "light",
  orientation: "portrait",
  viewport: "tablet",
  textScale: "1",
  safeArea: false,
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
    theme: state.theme,
    orientation: state.orientation,
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
    <div class="mock-shell">
      <aside class="mock-controls" aria-label="Preview controls (not part of app UI)">
        <h1 class="mock-controls__title">AlgoritiQ tablet mock</h1>
        <p class="mock-controls__hint">Each screen is its own HTML file under <code>screens/</code>. Controls here only affect the preview frame.</p>
        <label class="mock-field">
          <span>Screen</span>
          <select id="screen-select"></select>
        </label>
        <fieldset class="mock-field">
          <legend>Theme</legend>
          <label><input type="radio" name="theme" value="light" /> Light</label>
          <label><input type="radio" name="theme" value="dark" /> Dark</label>
        </fieldset>
        <fieldset class="mock-field">
          <legend>Orientation</legend>
          <label><input type="radio" name="orientation" value="portrait" /> Portrait</label>
          <label><input type="radio" name="orientation" value="landscape" /> Landscape</label>
        </fieldset>
        <label class="mock-field">
          <span>Viewport</span>
          <select id="viewport-select">
            <option value="tablet">Tablet — 800 × 1340 (adb)</option>
            <option value="narrow">Narrow (600 × 960)</option>
          </select>
        </label>
        <label class="mock-field">
          <span>Text size (system)</span>
          <select id="text-scale-select">
            <option value="1">100%</option>
            <option value="1.3">130%</option>
            <option value="2">200%</option>
          </select>
        </label>
        <label class="mock-field">
          <input type="checkbox" id="safe-area" />
          Show safe-area padding
        </label>
        <ol class="mock-flow">
          <li>License → Readiness → Clinic data</li>
          <li>Setup (profile → chambers → ready)</li>
          <li>Sign in → work scope → dashboard</li>
        </ol>
      </aside>
      <div class="mock-preview-wrap">
        <div id="device" class="device device--portrait">
          <div class="device-bezel">
            <div class="device-screen">
              <iframe id="screen-frame" title="Screen preview"></iframe>
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

  bindRadios("theme", "theme");
  bindRadios("orientation", "orientation");

  window.addEventListener("message", (event) => {
    if (event.data?.type === "mock-screen-ready") pushPreview();
  });

  applyDeviceChrome();
  loadScreen();
  syncRadios("theme", state.theme);
  syncRadios("orientation", state.orientation);
}

function bindRadios(name, key) {
  document.querySelectorAll(`input[name="${name}"]`).forEach((el) => {
    el.addEventListener("change", () => {
      if (!el.checked) return;
      state[key] = el.value;
      saveState(state);
      if (key === "orientation") applyDeviceChrome();
      pushPreview();
    });
  });
}

function syncRadios(name, value) {
  document.querySelectorAll(`input[name="${name}"]`).forEach((el) => {
    el.checked = el.value === value;
  });
}

function screenFile(id) {
  return screens.find((s) => s.id === id)?.file ?? "activation.html";
}

function loadScreen() {
  if (!frame) return;
  frame.src = `/screens/${screenFile(state.screen)}`;
}

function applyDeviceChrome() {
  const device = document.getElementById("device");
  device.classList.toggle("device--landscape", state.orientation === "landscape");
  device.classList.toggle("device--portrait", state.orientation !== "landscape");
  device.classList.toggle(
    "device--viewport-narrow",
    state.viewport === "narrow",
  );
}

function pushPreview() {
  frame?.contentWindow?.postMessage(previewPayload(state), "*");
}

mount();
