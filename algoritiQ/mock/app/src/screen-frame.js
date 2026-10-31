/** In-screen controls (theme / language) for static mocks. Preview shell can override via postMessage. */

function syncThemeButtons() {
  const dark = document.documentElement.dataset.theme === "dark";
  document.querySelectorAll("[data-mock-theme-toggle]").forEach((btn) => {
    btn.innerHTML = dark ? iconLightMode() : iconDarkMode();
    btn.setAttribute(
      "aria-label",
      dark ? "Switch to light theme" : "Switch to dark theme",
    );
  });
}

function iconDarkMode() {
  return `<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 0 1-4.4 2.26 5.403 5.403 0 0 1-3.14-9.8c-.44-.06-.9-.1-1.36-.1z"/></svg>`;
}

function iconLightMode() {
  return `<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 7a5 5 0 1 1 0 10 5 5 0 0 1 0-10zm0-5v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72 1.42 1.42M2 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>`;
}

function wireLanguageSwitchers() {
  document.querySelectorAll(".lang-switch").forEach((group) => {
    group.querySelectorAll(".lang-switch__seg").forEach((seg) => {
      seg.addEventListener("click", () => {
        if (seg.classList.contains("lang-switch__seg--on")) return;
        group
          .querySelectorAll(".lang-switch__seg")
          .forEach((s) => s.classList.remove("lang-switch__seg--on"));
        seg.classList.add("lang-switch__seg--on");
      });
    });
  });
}

function wireThemeToggles() {
  document.querySelectorAll("[data-mock-theme-toggle]").forEach((btn) => {
    btn.addEventListener("click", () => {
      const html = document.documentElement;
      const next = html.dataset.theme === "dark" ? "light" : "dark";
      html.dataset.theme = next;
      syncThemeButtons();
    });
  });
}

/** @param {Record<string, unknown>} cfg */
function applyPreview(cfg) {
  const html = document.documentElement;
  if (cfg.theme) html.dataset.theme = String(cfg.theme);
  const landscape = cfg.orientation === "landscape";
  html.classList.toggle("device-view--landscape", landscape);
  html.classList.toggle("device-view--portrait", !landscape);
  if (cfg.textScale != null) {
    document.body.style.zoom = String(cfg.textScale);
  }
  if (cfg.safeArea != null) {
    html.dataset.safeArea = cfg.safeArea ? "on" : "off";
  }
  syncThemeButtons();
}

window.addEventListener("message", (event) => {
  if (event.data?.type !== "mock-preview") return;
  applyPreview(event.data);
});

function wireDashboardDrawer() {
  document.querySelectorAll(".dashboard").forEach((root) => {
    const drawer = root.querySelector(".dashboard__drawer");
    const openBtn = root.querySelector("[data-drawer-open]");
    if (!drawer || !openBtn) return;

    const closeBtn = root.querySelector("[data-drawer-close]");
    const scrim = root.querySelector("[data-drawer-scrim]");

    /** @param {boolean} open */
    const setOpen = (open) => {
      root.classList.toggle("dashboard--drawer-open", open);
      drawer.setAttribute("aria-hidden", open ? "false" : "true");
      openBtn.setAttribute("aria-expanded", open ? "true" : "false");
      openBtn.setAttribute("aria-label", open ? "Close menu" : "Open menu");
      if (scrim) scrim.hidden = !open;
    };

    openBtn.addEventListener("click", () => {
      setOpen(!root.classList.contains("dashboard--drawer-open"));
    });
    closeBtn?.addEventListener("click", () => setOpen(false));
    scrim?.addEventListener("click", () => setOpen(false));
    root.querySelectorAll(".nav-tile").forEach((tile) => {
      tile.addEventListener("click", () => setOpen(false));
    });
  });
}

wireLanguageSwitchers();
wireThemeToggles();
wireDashboardDrawer();
syncThemeButtons();
window.parent.postMessage({ type: "mock-screen-ready" }, "*");
