import { renderDisplay, setCalled, wireMockControls } from "./tv-display.js";

const root = document.querySelector("[data-tv-display-root]");
setCalled(null);
renderDisplay(root);
wireMockControls(root);
