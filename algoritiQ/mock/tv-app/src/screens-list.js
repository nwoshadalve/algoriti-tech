/** @typedef {{ id: string, label: string, file: string }} ScreenEntry */

/** @type {ScreenEntry[]} */
export const screens = [
  { id: "pairing", label: "1 · Pair with tablet", file: "pairing.html" },
  { id: "setup-audio", label: "2 · Audio setup", file: "setup-audio.html" },
  { id: "display-idle", label: "3 · Display · Waiting", file: "display-idle.html" },
  { id: "display-live", label: "4 · Display · Called token", file: "display-live.html" },
  {
    id: "display-disconnected",
    label: "5 · Display · Disconnected",
    file: "display-disconnected.html",
  },
];
