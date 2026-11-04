import { renderDisplay, setCalled, wireMockControls } from "./tv-display.js";

const root = document.querySelector("[data-tv-display-root]");
setCalled({ kind: "regular", serial: 1008 });
renderDisplay(root);
wireMockControls(root);
