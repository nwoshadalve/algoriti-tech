/** @typedef {{ id: string, label: string, file: string }} ScreenEntry */

/** @type {ScreenEntry[]} */
export const screens = [
  { id: "activation", label: "1 · Activate device", file: "activation.html" },
  { id: "readiness", label: "2 · Tablet readiness", file: "readiness.html" },
  { id: "clinic-data", label: "3 · Clinic data", file: "clinic-data.html" },
  { id: "setup-profile", label: "4 · Setup · Profile", file: "setup-profile.html" },
  { id: "setup-chambers", label: "5 · Setup · Chambers", file: "setup-chambers.html" },
  { id: "setup-ready", label: "6 · Setup · Ready", file: "setup-ready.html" },
  { id: "sign-in", label: "7 · Sign in", file: "sign-in.html" },
  { id: "work-scope", label: "8 · Work scope", file: "work-scope.html" },
  { id: "admin-notice", label: "9 · Admin notice", file: "admin-notice.html" },
  { id: "board", label: "10 · Board (home)", file: "board.html" },
  { id: "connectivity", label: "11 · Connectivity", file: "connectivity.html" },
  { id: "settings", label: "12 · Settings", file: "settings.html" },
];
