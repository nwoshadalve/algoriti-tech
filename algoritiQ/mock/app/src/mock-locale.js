/** Locale for static tablet mocks (same storage key as production web). */

import catalogs from "./mock-l10n-data.json";

const STORAGE_KEY = "algoritiq.locale";

/** @typedef {'en' | 'bn'} Locale */

/** @type {Locale} */
let current = readLocale();

function readLocale() {
  try {
    return localStorage.getItem(STORAGE_KEY) === "bn" ? "bn" : "en";
  } catch {
    return "en";
  }
}

/** @param {Record<string, string | number>} [params] */
function format(template, params) {
  if (!params) return template;
  return template.replace(/\{(\w+)\}/g, (_, key) =>
    String(params[key] ?? `{${key}}`),
  );
}

/** @param {string} key @param {Record<string, string | number>} [params] */
export function t(key, params) {
  const table = catalogs[current] ?? catalogs.en;
  const fallback = catalogs.en[key] ?? key;
  return format(table[key] ?? fallback, params);
}

export function getLocale() {
  return current;
}

/** @param {Locale} locale */
export function setLocale(locale) {
  if (locale !== "en" && locale !== "bn") return;
  current = locale;
  try {
    localStorage.setItem(STORAGE_KEY, locale);
  } catch {
    /* preview iframe may block storage */
  }
  applyDocumentLocale();
  window.dispatchEvent(
    new CustomEvent("mock-locale-change", { detail: { locale } }),
  );
}

function applyTextNode(el, key, params) {
  const text = t(key, params);
  if (el.tagName === "INPUT" || el.tagName === "TEXTAREA") {
    if (el.hasAttribute("data-l10n-placeholder")) {
      el.placeholder = t(el.getAttribute("data-l10n-placeholder"), params);
    }
    return;
  }
  el.textContent = text;
}

export function applyDocumentLocale() {
  const locale = current;
  document.documentElement.lang = locale === "bn" ? "bn" : "en";

  document.querySelectorAll("[data-l10n]").forEach((el) => {
    const key = el.getAttribute("data-l10n");
    if (!key) return;
    let params;
    const raw = el.getAttribute("data-l10n-params");
    if (raw) {
      try {
        params = JSON.parse(raw);
      } catch {
        params = undefined;
      }
    }
    applyTextNode(el, key, params);
  });

  document.querySelectorAll("[data-l10n-placeholder]").forEach((el) => {
    if (!(el instanceof HTMLInputElement || el instanceof HTMLTextAreaElement)) {
      return;
    }
    const key = el.getAttribute("data-l10n-placeholder");
    if (!key) return;
    el.placeholder = t(key);
  });

  document.querySelectorAll("[data-l10n-aria]").forEach((el) => {
    const key = el.getAttribute("data-l10n-aria");
    if (key) el.setAttribute("aria-label", t(key));
  });

  syncLangSwitchers();
}

export function syncLangSwitchers() {
  const locale = current;
  document.querySelectorAll(".lang-switch").forEach((group) => {
    group.querySelectorAll(".lang-switch__seg").forEach((seg) => {
      const on = seg.getAttribute("data-lang") === locale;
      seg.classList.toggle("lang-switch__seg--on", on);
      seg.setAttribute("aria-pressed", on ? "true" : "false");
    });
    const labelKey = group.getAttribute("data-l10n-aria");
    if (labelKey) group.setAttribute("aria-label", t(labelKey));
  });
}
