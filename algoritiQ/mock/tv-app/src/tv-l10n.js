import data from "./tv-l10n-data.json";

/** @param {string} key @param {Record<string, string>=} vars */
export function t(key, vars) {
  const table = data.bn;
  let text = table[key] ?? key;
  if (vars) {
    for (const [k, v] of Object.entries(vars)) {
      text = text.replace(`{${k}}`, v);
    }
  }
  return text;
}

export function applyDocumentLocale() {
  document.documentElement.lang = "bn";
  document.documentElement.classList.add("locale-bn");
  document.querySelectorAll("[data-l10n]").forEach((el) => {
    const key = el.getAttribute("data-l10n");
    if (key) el.textContent = t(key);
  });
}

/** @param {number} n */
export function formatSerial(n) {
  return String(n).replace(/\d/g, (d) => "০১২৩৪৫৬৭৮৯"[Number(d)]);
}
