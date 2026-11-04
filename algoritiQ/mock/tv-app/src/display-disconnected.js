import { renderDisplay, setCalled } from "./tv-display.js";

const root = document.querySelector("[data-tv-display-root]");
setCalled({ kind: "regular", serial: 1007 });
renderDisplay(root);
