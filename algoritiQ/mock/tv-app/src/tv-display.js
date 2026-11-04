import session from "./mock-session-data.json";
import { formatSerial, t } from "./tv-l10n.js";

/** @typedef {"regular" | "report" | "dressing"} QueueKind */

export const MAX_WAITING_VISIBLE = 5;

/** @type {Record<QueueKind, string>} */
const queueLabelByKind = {
  regular: "queueRegular",
  report: "queueReport",
  dressing: "queueDressing",
};

/** @type {{ kind: QueueKind, serial: number } | null} */
export let called = { kind: "regular", serial: 1008 };

/** @type {Record<QueueKind, number[]>} */
export const waiting = {
  regular: [1009, 1010, 1011, 1012, 1013, 1014],
  report: [2003, 2004, 2005],
  dressing: [3002],
};

export { session };

const BN = "০১২৩৪৫৬৭৮৯";

/** @param {string} text */
export function toBnDigits(text) {
  return String(text).replace(/\d/g, (d) => BN[Number(d)]);
}

/** @param {string} phone */
export function formatPhoneBn(phone) {
  const digits = phone.replace(/\D/g, "");
  if (digits.length === 11 && digits.startsWith("01")) {
    return toBnDigits(`${digits.slice(0, 5)}-${digits.slice(5)}`);
  }
  return toBnDigits(digits);
}

/** @param {string} reg */
export function formatBmdcBn(reg) {
  return toBnDigits(reg.toUpperCase());
}

/** @param {{ kind: QueueKind, serial: number } | null} next */
export function setCalled(next) {
  called = next;
}

/** @param {QueueKind} kind */
export function callNextFromQueue(kind) {
  const list = waiting[kind];
  if (!list.length) return false;
  const serial = list.shift();
  if (serial == null) return false;
  called = { kind, serial };
  return true;
}

/** @param {HTMLElement | null | undefined} root */
export function renderIdentity(root) {
  if (!root) return;
  const { doctor, chamber } = session;

  const img = root.querySelector("[data-tv-doctor-photo]");
  const fallback = root.querySelector("[data-tv-doctor-photo-fallback]");
  if (img instanceof HTMLImageElement) {
    img.onload = () => {
      if (fallback) fallback.hidden = true;
    };
    img.onerror = () => {
      img.hidden = true;
      if (fallback) fallback.hidden = false;
    };
    img.src = `${doctor.photoUrl}?v=${doctor.photoVersion ?? 0}`;
    img.alt = doctor.name;
  }

  setText(root, "[data-tv-doctor-name]", doctor.name);
  setText(root, "[data-tv-doctor-degrees]", doctor.degrees.join(" · "));
  setText(root, "[data-tv-doctor-designation]", doctor.designation);
  setText(root, "[data-tv-doctor-specialty]", doctor.specialty);
  setText(root, "[data-tv-doctor-workplace]", doctor.workplace);
  setText(
    root,
    "[data-tv-doctor-bmdc]",
    t("bmdcLabel", { number: formatBmdcBn(doctor.registrationNumber) }),
  );
  setText(root, "[data-tv-chamber-name]", chamber.name);
  setText(root, "[data-tv-chamber-location]", chamber.location);
  setText(
    root,
    "[data-tv-chamber-phone]",
    t("chamberPhoneLabel", { phone: formatPhoneBn(chamber.phone) }),
  );
}

const AUDIENCE_CLOCK_TZ = "Asia/Dhaka";

/** @param {ParentNode | null | undefined} root */
export function startAudienceClock(root) {
  const el = root?.querySelector("[data-tv-clock]");
  if (!(el instanceof HTMLElement)) return;

  const tick = () => {
    const now = new Date();
    const formatted = new Intl.DateTimeFormat("bn-BD", {
      hour: "numeric",
      minute: "2-digit",
      hour12: true,
      timeZone: AUDIENCE_CLOCK_TZ,
    }).format(now);
    el.textContent = toBnDigits(formatted);
  };

  tick();
  window.setInterval(tick, 30_000);
}

/** @param {HTMLElement | null | undefined} root */
export function renderDisplay(root) {
  if (!root) return;
  renderIdentity(root);

  const calledEl = root.querySelector("[data-tv-called-serial]");
  const badgeEl = root.querySelector("[data-tv-called-type]");
  const emptyEl = root.querySelector("[data-tv-called-empty]");
  const announceEl = root.querySelector("[data-tv-called-panel]");
  const speakerEl = root.querySelector("[data-tv-announce-speaker]");

  if (called && calledEl && badgeEl) {
    calledEl.textContent = formatSerial(called.serial);
    badgeEl.textContent = t(queueLabelByKind[called.kind]);
    badgeEl.hidden = false;
    calledEl.classList.add("is-live");
    if (emptyEl) emptyEl.hidden = true;
    announceEl?.classList.remove("is-idle");
    if (speakerEl) speakerEl.hidden = false;
  } else if (calledEl && emptyEl) {
    calledEl.textContent = "—";
    calledEl.classList.remove("is-live");
    emptyEl.hidden = false;
    announceEl?.classList.add("is-idle");
    if (speakerEl) speakerEl.hidden = true;
    if (badgeEl) {
      badgeEl.textContent = "";
      badgeEl.hidden = true;
    }
  }

  root.querySelectorAll("[data-tv-waiting]").forEach((row) => {
    const kind = /** @type {QueueKind | null} */ (row.getAttribute("data-tv-waiting"));
    if (!kind) return;
    const listEl = row.querySelector("[data-tv-serial-list]");
    const moreEl = row.querySelector("[data-tv-serial-more]");
    if (!listEl) return;
    const all = waiting[kind];
    const visible = all.slice(0, MAX_WAITING_VISIBLE);
    const hiddenCount = all.length - visible.length;
    listEl.innerHTML = "";
    for (const serial of visible) {
      const li = document.createElement("li");
      li.className = "queue-chip";
      li.textContent = formatSerial(serial);
      listEl.appendChild(li);
    }
    if (moreEl) {
      moreEl.hidden = hiddenCount <= 0;
      if (hiddenCount > 0) {
        moreEl.textContent = t("waitingMore", {
          count: formatSerial(hiddenCount),
        });
      }
    }
  });
}

/** @param {HTMLElement | null | undefined} root */
export function wireMockControls(root) {
  const bar = root?.querySelector("[data-tv-mock-bar]");
  if (!bar || !root) return;
  const onCall = () => {
    renderDisplay(root);
    pulseSpeaker(root);
  };
  bar.querySelector("[data-tv-call-regular]")?.addEventListener("click", () => {
    if (callNextFromQueue("regular")) onCall();
  });
  bar.querySelector("[data-tv-call-report]")?.addEventListener("click", () => {
    if (callNextFromQueue("report")) onCall();
  });
  bar.querySelector("[data-tv-call-dressing]")?.addEventListener("click", () => {
    if (callNextFromQueue("dressing")) onCall();
  });
  bar.querySelector("[data-tv-clear-called]")?.addEventListener("click", () => {
    setCalled(null);
    renderDisplay(root);
  });
}

/** @param {HTMLElement | null | undefined} root */
function pulseSpeaker(root) {
  const speaker = root?.querySelector("[data-tv-announce-speaker]");
  if (!speaker) return;
  speaker.classList.remove("is-pulse");
  void speaker.offsetWidth;
  speaker.classList.add("is-pulse");
}

/** @param {ParentNode} root @param {string} sel @param {string} text */
function setText(root, sel, text) {
  const el = root.querySelector(sel);
  if (el) el.textContent = text;
}

window.addEventListener("tv-locale-change", () => {
  document.querySelectorAll("[data-tv-display-root]").forEach((root) => {
    renderDisplay(/** @type {HTMLElement} */ (root));
  });
});
