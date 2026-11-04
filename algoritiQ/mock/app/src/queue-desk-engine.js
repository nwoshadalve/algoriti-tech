/**
 * In-memory queue desk — mirrors web `queueDesk.ts` + patient-entry spec for the tablet mock.
 * Persists to localStorage; reset via resetDemoData().
 */

export const STORAGE_KEY = "algoritiq-mock-queue-desk-v2";

export const QUEUE_TYPES = [
  {
    id: "qt_regular",
    englishName: "Regular",
    bengaliName: "সাধারণ",
    start: 1001,
    end: 1099,
    nextSerial: 1005,
  },
  {
    id: "qt_report",
    englishName: "Report",
    bengaliName: "রিপোর্ট",
    start: 2001,
    end: 2099,
    nextSerial: 2002,
  },
  {
    id: "qt_dressing",
    englishName: "Dressing",
    bengaliName: "ড্রেসিং",
    start: 3001,
    end: 3099,
    nextSerial: 3002,
  },
];

const CHAMBER_ID = "ch_main";
const CHAMBER_NAME = "Main chamber";

function minutesAgo(m) {
  return new Date(Date.now() - m * 60_000).toISOString();
}

function defaultState() {
  return {
    chamberId: CHAMBER_ID,
    chamberName: CHAMBER_NAME,
    sessionId: "sess_demo",
    sessionOpen: true,
    nextPatientNum: 6,
    nextPrintAttempt: 1,
    printSimulation: "success",
    queueNextSerial: {
      qt_regular: 1005,
      qt_report: 2002,
      qt_dressing: 3002,
    },
    patients: [
      {
        id: "pat_1",
        clinicPatientId: "P-000001",
        bengaliName: "মোহাম্মদ রহিম",
        englishName: "Mohammad Rahim",
        phone: "01711111111",
        ageLabel: "45 yrs",
        locality: "Dhanmondi",
        gender: "male",
        legacyFileNumber: "",
        hasPaperFile: false,
        adminNote: "",
      },
      {
        id: "pat_2",
        clinicPatientId: "P-000002",
        bengaliName: "ফাতেমা বেগম",
        englishName: "Fatema Begum",
        phone: "01722222222",
        ageLabel: "32 yrs",
        locality: "",
        gender: "female",
        legacyFileNumber: "",
        hasPaperFile: false,
        adminNote: "",
      },
      {
        id: "pat_3",
        clinicPatientId: "P-000003",
        bengaliName: "করিম উদ্দিন",
        englishName: "",
        phone: "01711111111",
        ageLabel: "12 yrs",
        locality: "",
        gender: "male",
        legacyFileNumber: "LF-8821",
        hasPaperFile: true,
        adminNote: "",
      },
      {
        id: "pat_4",
        clinicPatientId: "P-000004",
        bengaliName: "সাহানা আহমেদ",
        englishName: "Sahana Ahmed",
        phone: "01833334444",
        ageLabel: "28 yrs",
        locality: "Mirpur",
        gender: "female",
        legacyFileNumber: "",
        hasPaperFile: false,
        adminNote: "",
      },
      {
        id: "pat_5",
        clinicPatientId: "P-000005",
        bengaliName: "আব্দুল জলিল",
        englishName: "Abdul Jalil",
        phone: "01955556666",
        ageLabel: "58 yrs",
        locality: "",
        gender: "male",
        legacyFileNumber: "",
        hasPaperFile: false,
        adminNote: "",
      },
    ],
    tokens: [
      {
        id: "tok_1",
        serial: 1001,
        queueTypeId: "qt_regular",
        patientId: "pat_1",
        status: "WAITING",
        issuedAt: minutesAgo(42),
        firstCalledAt: null,
        enteredAt: null,
        cancelledAt: null,
        cancelReason: null,
        feeBdt: 500,
        latestPrintStatus: "SENT",
        reprintCount: 0,
      },
      {
        id: "tok_2",
        serial: 1002,
        queueTypeId: "qt_regular",
        patientId: "pat_2",
        status: "WAITING",
        issuedAt: minutesAgo(28),
        firstCalledAt: null,
        enteredAt: null,
        cancelledAt: null,
        cancelReason: null,
        feeBdt: null,
        latestPrintStatus: "FAILED",
        reprintCount: 0,
      },
      {
        id: "tok_3",
        serial: 1003,
        queueTypeId: "qt_regular",
        patientId: "pat_4",
        status: "ENTERED",
        issuedAt: minutesAgo(95),
        firstCalledAt: minutesAgo(80),
        enteredAt: minutesAgo(72),
        cancelledAt: null,
        cancelReason: null,
        feeBdt: 500,
        latestPrintStatus: "SENT",
        reprintCount: 0,
      },
      {
        id: "tok_4",
        serial: 1004,
        queueTypeId: "qt_regular",
        patientId: "pat_5",
        status: "CALLED",
        issuedAt: minutesAgo(18),
        firstCalledAt: minutesAgo(4),
        enteredAt: null,
        cancelledAt: null,
        cancelReason: null,
        feeBdt: 500,
        latestPrintStatus: "SENT",
        reprintCount: 0,
      },
    ],
    printerBusyTokenId: null,
    printerLockUntil: 0,
    announcementPlaying: false,
    commandResults: {},
    printAttempts: [],
    auditLog: [
      { at: minutesAgo(4), action: "token.called", detail: "Serial 1004 — announcement queued" },
      { at: minutesAgo(28), action: "print.failed", detail: "Serial 1002 — Bluetooth timeout" },
    ],
  ui: {
    searchQuery: "",
    selectedPatientId: null,
    queueTypeId: "",
    feeBdt: "",
    formBengaliName: "",
    formPhone: "",
    formGender: "",
    formAgeLabel: "",
    formEnglishName: "",
    formHasPaperFile: false,
    formLegacyFileNumber: "",
    formAdminNote: "",
    deskPanel: "idle",
    duplicateWarning: null,
    modal: null,
    toast: null,
  },
  };
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return defaultState();
    const parsed = JSON.parse(raw);
    const base = defaultState();
    return {
      ...base,
      ...parsed,
      queueNextSerial: { ...base.queueNextSerial, ...parsed.queueNextSerial },
      ui: { ...base.ui, ...parsed.ui },
    };
  } catch {
    return defaultState();
  }
}

let state = loadState();

/** @type {Set<() => void>} */
const listeners = new Set();

function persist() {
  try {
    const { ui, ...rest } = state;
    localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({
        ...rest,
        ui: { ...ui, modal: null, toast: null },
      }),
    );
  } catch {
    /* ignore quota */
  }
}

function emit() {
  persist();
  listeners.forEach((fn) => fn());
}

export function subscribe(fn) {
  listeners.add(fn);
  return () => listeners.delete(fn);
}

export function getState() {
  return state;
}

export function resetDemoData() {
  state = defaultState();
  emit();
}

export function setPrintSimulation(mode) {
  state.printSimulation = mode;
  emit();
}

function normalizePhone(raw) {
  const digits = String(raw || "").replace(/\D/g, "");
  if (digits.length >= 10) return digits.slice(-10);
  return digits;
}

function formatPatientId(n) {
  return `P-${String(n).padStart(6, "0")}`;
}

function normalizePatientIdQuery(q) {
  const t = String(q || "")
    .trim()
    .toUpperCase()
    .replace(/^P-?/, "");
  const num = parseInt(t, 10);
  if (Number.isNaN(num)) return null;
  return formatPatientId(num);
}

function queueType(id) {
  return QUEUE_TYPES.find((q) => q.id === id);
}

function patientById(id) {
  return state.patients.find((p) => p.id === id);
}

function audit(action, detail) {
  state.auditLog.unshift({
    at: new Date().toISOString(),
    action,
    detail,
  });
  state.auditLog = state.auditLog.slice(0, 40);
}

function enrichToken(token) {
  const qt = queueType(token.queueTypeId);
  const patient = patientById(token.patientId);
  return {
    id: token.id,
    serial: token.serial,
    queueTypeId: token.queueTypeId,
    queueEnglishName: qt?.englishName ?? "",
    queueBengaliName: qt?.bengaliName ?? "",
    patientId: token.patientId,
    clinicPatientId: patient?.clinicPatientId ?? "—",
    patientBengaliName: patient?.bengaliName ?? "—",
    status: token.status,
    issuedAt: token.issuedAt,
    firstCalledAt: token.firstCalledAt,
    enteredAt: token.enteredAt,
    feeBdt: token.feeBdt,
    latestPrintStatus: token.latestPrintStatus,
    cancelReason: token.cancelReason,
    reprintCount: token.reprintCount,
  };
}

export function getCalledToken() {
  const t = state.tokens.find((row) => row.status === "CALLED");
  return t ? enrichToken(t) : null;
}

export function getSessionTokens() {
  return [...state.tokens]
    .map(enrichToken)
    .sort((a, b) => b.issuedAt.localeCompare(a.issuedAt));
}

export function getSnapshot() {
  const called = getCalledToken();
  const controls = QUEUE_TYPES.map((qt) => {
    const waitingCount = state.tokens.filter(
      (t) => t.queueTypeId === qt.id && t.status === "WAITING",
    ).length;
    const latestCalled = state.tokens.find(
      (t) => t.queueTypeId === qt.id && t.status === "CALLED",
    );
    return {
      queueTypeId: qt.id,
      englishName: qt.englishName,
      bengaliName: qt.bengaliName,
      waitingCount,
      nextSerial: state.queueNextSerial[qt.id] ?? qt.start,
      canCallNext: state.sessionOpen && !called && waitingCount > 0,
      canRecall: !!latestCalled && (!called || called.queueTypeId === qt.id),
    };
  });

  return {
    chamberId: state.chamberId,
    chamberName: state.chamberName,
    sessionId: state.sessionId,
    sessionOpen: state.sessionOpen,
    calledToken: called,
    queueControls: controls,
    tokens: getSessionTokens(),
    printerBusyTokenId: state.printerBusyTokenId,
    announcementPlaying: state.announcementPlaying,
    auditLog: state.auditLog,
  };
}

export function startSession() {
  if (state.sessionOpen) return;
  state.sessionId = `sess_${Date.now()}`;
  state.sessionOpen = true;
  state.ui.duplicateWarning = null;
  audit("session.start", state.chamberName);
  showToast("Session started");
  emit();
}

export function setDeskPanel(_mode) {
  /* legacy no-op — patient flows use modals */
}

export function endSession() {
  if (!state.sessionOpen) return;
  state.sessionOpen = false;
  state.sessionId = null;
  state.ui.modal = null;
  audit("session.end", state.chamberName);
  showToast("Session ended");
  emit();
}

export function searchPatients(query) {
  const q = String(query || "").trim();
  if (q.length < 2) return [];
  const idMatch = normalizePatientIdQuery(q);
  const phone = normalizePhone(q);
  return state.patients.filter((p) => {
    if (idMatch && p.clinicPatientId === idMatch) return true;
    if (phone.length >= 2 && normalizePhone(p.phone) === phone) return true;
    if (phone.length >= 2 && normalizePhone(p.phone).includes(phone)) return true;
    if (q.length >= 2 && p.bengaliName.includes(q)) return true;
    return false;
  });
}

function activeTokenForPatient(patientId) {
  return state.tokens.find(
    (t) =>
      t.patientId === patientId &&
      (t.status === "WAITING" || t.status === "CALLED"),
  );
}

export function setUi(patch) {
  if (patch.modal !== undefined) {
    state.ui.modal = patch.modal;
    const { modal, ...rest } = patch;
    Object.assign(state.ui, rest);
  } else {
    Object.assign(state.ui, patch);
  }
  emit();
}

export function showToast(message, tone = "ok") {
  state.ui.toast = { message, tone, at: Date.now() };
  emit();
  window.setTimeout(() => {
    if (state.ui.toast?.message === message) {
      state.ui.toast = null;
      emit();
    }
  }, 3200);
}

export function openPatientEntryModal() {
  state.ui.searchQuery = "";
  state.ui.selectedPatientId = null;
  state.ui.duplicateWarning = null;
  clearPatientFormFields();
  state.ui.modal = { kind: "patient-entry" };
  emit();
}

function clearPatientFormFields() {
  state.ui.queueTypeId = QUEUE_TYPES.length === 1 ? QUEUE_TYPES[0].id : "";
  state.ui.feeBdt = "";
  state.ui.formBengaliName = "";
  state.ui.formPhone = "";
  state.ui.formGender = "";
  state.ui.formAgeLabel = "";
  state.ui.formEnglishName = "";
  state.ui.formHasPaperFile = false;
  state.ui.formLegacyFileNumber = "";
  state.ui.formAdminNote = "";
}

function syncFormFromPatient(p) {
  state.ui.formBengaliName = p.bengaliName;
  state.ui.formPhone = p.phone;
  state.ui.formGender = p.gender || "";
  state.ui.formAgeLabel = p.ageLabel || "";
  state.ui.formEnglishName = p.englishName || "";
  state.ui.formHasPaperFile = Boolean(p.hasPaperFile);
  state.ui.formLegacyFileNumber = p.legacyFileNumber || "";
  state.ui.formAdminNote = p.adminNote || "";
}

/** @param {string} bind @param {string | boolean} value */
export function setFormBind(bind, value) {
  switch (bind) {
    case "search":
      state.ui.searchQuery = String(value);
      break;
    case "form-bengali-name":
      state.ui.formBengaliName = String(value);
      break;
    case "form-phone":
      state.ui.formPhone = String(value);
      break;
    case "form-queue":
      state.ui.queueTypeId = String(value);
      break;
    case "form-fee":
      state.ui.feeBdt = String(value);
      break;
    case "form-age":
      state.ui.formAgeLabel = String(value);
      break;
    case "form-gender":
      state.ui.formGender = String(value);
      break;
    case "form-english-name":
      state.ui.formEnglishName = String(value);
      break;
    case "form-paper-file":
      state.ui.formHasPaperFile = Boolean(value);
      break;
    case "form-legacy-file":
      state.ui.formLegacyFileNumber = String(value);
      break;
    case "form-admin-note":
      state.ui.formAdminNote = String(value);
      break;
    default:
      break;
  }
  emit();
}

export function applyFormToPatient(patientId) {
  const p = patientById(patientId);
  if (!p) return;
  p.bengaliName = state.ui.formBengaliName.trim() || p.bengaliName;
  p.phone = state.ui.formPhone.trim() || p.phone;
  p.gender = state.ui.formGender || p.gender;
  p.ageLabel = state.ui.formAgeLabel.trim();
  p.englishName = state.ui.formEnglishName.trim();
  p.hasPaperFile = state.ui.formHasPaperFile;
  p.legacyFileNumber = state.ui.formLegacyFileNumber.trim();
  p.adminNote = state.ui.formAdminNote.trim();
}

export function setSearchQuery(q) {
  state.ui.searchQuery = q;
  emit();
}

export function selectPatient(patientId) {
  const p = patientById(patientId);
  state.ui.selectedPatientId = patientId;
  if (p) syncFormFromPatient(p);
  if (QUEUE_TYPES.length === 1) {
    state.ui.queueTypeId = QUEUE_TYPES[0].id;
  }
  emit();
}

function previewSerial(queueTypeId) {
  const qt = queueType(queueTypeId);
  return state.queueNextSerial[queueTypeId] ?? qt?.start ?? 0;
}

export function buildIssuePreview(patientId, queueTypeId, feeBdt) {
  const patient = patientById(patientId);
  const qt = queueType(queueTypeId);
  if (!patient || !qt) return null;
  return {
    patient,
    chamberName: state.chamberName,
    queueTypeId,
    queueEnglishName: qt.englishName,
    queueBengaliName: qt.bengaliName,
    previewSerial: previewSerial(queueTypeId),
    feeBdt: feeBdt ?? null,
  };
}

export function beginIssuePreview() {
  if (!state.sessionOpen) {
    showToast("Start a session first", "warn");
    return;
  }
  const queueTypeId =
    state.ui.queueTypeId || (QUEUE_TYPES.length === 1 ? QUEUE_TYPES[0].id : "");
  if (!state.ui.formBengaliName.trim() || !state.ui.formPhone.trim() || !queueTypeId) {
    showToast("Bengali name, phone, and queue type are required", "warn");
    return;
  }
  if (!state.ui.selectedPatientId) {
    showToast("Select a patient from search results", "warn");
    return;
  }

  applyFormToPatient(state.ui.selectedPatientId);
  const patient = patientById(state.ui.selectedPatientId);
  if (!patient) return;

  const active = activeTokenForPatient(patient.id);
  if (active) {
    state.ui.modal = { kind: "active-token", tokenId: active.id };
    emit();
    return;
  }

  const fee = state.ui.feeBdt.trim();
  state.ui.modal = {
    kind: "issue-confirm",
    patientId: patient.id,
    queueTypeId,
    feeBdt: fee ? Number(fee) : null,
    previewSerial: previewSerial(queueTypeId),
  };
  emit();
}

function allocateSerial(queueTypeId) {
  const qt = queueType(queueTypeId);
  if (!qt) return { error: "range_exhausted" };
  const serial = state.queueNextSerial[queueTypeId] ?? qt.start;
  if (serial > qt.end) return { error: "range_exhausted" };
  state.queueNextSerial[queueTypeId] = serial + 1;
  return { serial };
}

function releasePrinterLock() {
  state.printerBusyTokenId = null;
  state.printerLockUntil = 0;
}

function simulatePrint(tokenId, { isReprint = false, onComplete } = {}) {
  if (state.printerBusyTokenId && Date.now() < state.printerLockUntil) {
    showToast("Printer busy", "warn");
    return null;
  }
  const token = state.tokens.find((t) => t.id === tokenId);
  if (!token) return null;

  const attemptId = `pa_${state.nextPrintAttempt++}`;
  state.printerBusyTokenId = tokenId;
  state.printerLockUntil = Date.now() + 8000;
  token.latestPrintStatus = "PENDING";

  const attempt = {
    id: attemptId,
    tokenId,
    serial: token.serial,
    isReprint,
    reason: isReprint ? "reprint" : "issue",
    status: "PENDING",
    at: new Date().toISOString(),
  };
  state.printAttempts.unshift(attempt);
  audit(isReprint ? "print.reprint" : "print.issue", `Serial ${token.serial} — sending`);

  emit();

  window.setTimeout(() => {
    const row = state.tokens.find((t) => t.id === tokenId);
    const mode = state.printSimulation;
    let status = "SENT";
    if (mode === "fail") status = "FAILED";
    else if (mode === "unknown") status = "UNKNOWN";
    else if (mode === "random") {
      const r = Math.random();
      if (r < 0.15) status = "FAILED";
      else if (r < 0.25) status = "UNKNOWN";
    }

    if (row) row.latestPrintStatus = status;
    attempt.status = status;
    if (isReprint && status === "SENT") row.reprintCount += 1;

    releasePrinterLock();
    audit(`print.${status.toLowerCase()}`, `Serial ${token.serial}`);
    emit();
    if (onComplete) onComplete({ status, token: row ? enrichToken(row) : null, attemptId });
    else {
      showToast(
        status === "SENT"
          ? isReprint
            ? "Reprint sent"
            : "Print sent"
          : status === "UNKNOWN"
            ? "Print unknown — check printer"
            : "Print failed — token still valid",
        status === "SENT" ? "ok" : "warn",
      );
    }
  }, 1600);

  return attemptId;
}

export function confirmIssue() {
  const modal = state.ui.modal;
  if (!modal || modal.kind !== "issue-confirm") return;
  const patient = patientById(modal.patientId);
  const qt = queueType(modal.queueTypeId);
  if (!patient || !qt) return;

  const alloc = allocateSerial(modal.queueTypeId);
  if (alloc.error) {
    showToast("Serial range exhausted for this queue", "warn");
    return;
  }

  const id = `tok_${Date.now()}`;
  const token = {
    id,
    serial: alloc.serial,
    queueTypeId: modal.queueTypeId,
    patientId: patient.id,
    status: "WAITING",
    issuedAt: new Date().toISOString(),
    firstCalledAt: null,
    enteredAt: null,
    cancelledAt: null,
    cancelReason: null,
    feeBdt: modal.feeBdt,
    latestPrintStatus: "PENDING",
    reprintCount: 0,
  };
  state.tokens.push(token);
  audit("token.issued", `Serial ${alloc.serial} · ${patient.clinicPatientId}`);

  state.ui.modal = {
    kind: "print-slip",
    tokenId: id,
    isReprint: false,
  };
  state.ui.selectedPatientId = null;
  state.ui.searchQuery = "";
  clearPatientFormFields();
  emit();

  simulatePrint(id, {
    onComplete: ({ status, token: view }) => {
      state.ui.modal = {
        kind: "print-slip",
        tokenId: id,
        isReprint: false,
        printStatus: status,
        tokenView: view,
      };
      emit();
    },
  });
}

export function registerPatient(payload) {
  const phoneNorm = normalizePhone(payload.phone);
  const similar = state.patients.filter(
    (p) => normalizePhone(p.phone) === phoneNorm && phoneNorm.length >= 10,
  );
  if (similar.length && !payload.confirmDuplicatePhone) {
    state.ui.duplicateWarning = similar.map((p) => p.clinicPatientId);
    state.ui.modal = { kind: "register" };
    emit();
    return { needsConfirm: true };
  }
  state.ui.duplicateWarning = null;

  if (!payload.bengaliName?.trim() || !payload.phone?.trim()) {
    showToast("Bengali name and phone required", "warn");
    return {};
  }
  if (!payload.queueTypeId) {
    showToast("Queue type is required", "warn");
    return {};
  }

  const num = state.nextPatientNum++;
  const patient = {
    id: `pat_${num}`,
    clinicPatientId: formatPatientId(num),
    bengaliName: payload.bengaliName.trim(),
    englishName: payload.englishName?.trim() || "",
    phone: payload.phone.trim(),
    ageLabel: payload.approxAge?.trim() || payload.ageLabel?.trim() || "",
    gender: payload.gender || "",
    legacyFileNumber: payload.legacyFileNumber?.trim() || "",
    hasPaperFile: Boolean(payload.hasPaperFile),
    adminNote: payload.adminNote?.trim() || "",
  };
  state.patients.push(patient);
  audit("patient.registered", patient.clinicPatientId);

  state.ui.selectedPatientId = patient.id;
  syncFormFromPatient(patient);
  state.ui.queueTypeId = payload.queueTypeId;
  state.ui.feeBdt = payload.feeBdt ? String(payload.feeBdt) : "";
  state.ui.modal = null;
  showToast(`${patient.clinicPatientId} saved`);
  emit();
  beginIssuePreview();
  return { patient };
}

export function updatePatient(patientId, patch) {
  const p = patientById(patientId);
  if (!p) return;
  if (patch.bengaliName) p.bengaliName = patch.bengaliName.trim();
  if (patch.phone) p.phone = patch.phone.trim();
  if (patch.englishName !== undefined) p.englishName = patch.englishName.trim();
  if (patch.ageLabel !== undefined) p.ageLabel = patch.ageLabel.trim();
  if (patch.gender !== undefined) p.gender = patch.gender;
  if (patch.adminNote !== undefined) p.adminNote = patch.adminNote.trim();
  if (patch.legacyFileNumber !== undefined) p.legacyFileNumber = patch.legacyFileNumber.trim();
  if (patch.hasPaperFile !== undefined) p.hasPaperFile = patch.hasPaperFile;
  audit("patient.updated", p.clinicPatientId);
  showToast("Patient updated");
  emit();
}

export function openRegisterModal(initialPhone = "") {
  clearPatientFormFields();
  state.ui.formPhone = initialPhone;
  state.ui.duplicateWarning = null;
  state.ui.modal = { kind: "register" };
  emit();
}

export function openEditPatient(patientId) {
  const p = patientById(patientId);
  if (!p) return;
  syncFormFromPatient(p);
  state.ui.modal = { kind: "edit-patient", patientId };
  emit();
}

export function callNext(queueTypeId) {
  if (!state.sessionOpen) {
    showToast("Session closed", "warn");
    return;
  }
  const unresolved = getCalledToken();
  if (unresolved) {
    state.ui.modal = { kind: "unresolved-call", tokenId: unresolved.id };
    emit();
    return;
  }
  const waiting = state.tokens
    .filter((t) => t.queueTypeId === queueTypeId && t.status === "WAITING")
    .sort((a, b) => a.issuedAt.localeCompare(b.issuedAt));
  const next = waiting[0];
  if (!next) {
    showToast("No waiting token", "warn");
    return;
  }
  next.status = "CALLED";
  if (!next.firstCalledAt) next.firstCalledAt = new Date().toISOString();
  state.announcementPlaying = true;
  audit("token.called", `Serial ${next.serial}`);
  showToast(`Called ${next.serial}`);
  emit();
  window.setTimeout(() => {
    state.announcementPlaying = false;
    emit();
  }, 2500);
}

export function recall(queueTypeId) {
  const called = state.tokens.find(
    (t) => t.queueTypeId === queueTypeId && t.status === "CALLED",
  );
  if (!called) {
    showToast("Nothing to recall", "warn");
    return;
  }
  state.announcementPlaying = true;
  audit("token.recall", `Serial ${called.serial}`);
  showToast(`Recall ${called.serial}`);
  emit();
  window.setTimeout(() => {
    state.announcementPlaying = false;
    emit();
  }, 2000);
}

export function markEntered(tokenId) {
  const token = state.tokens.find((t) => t.id === tokenId);
  if (!token || token.status !== "CALLED") return;
  token.status = "ENTERED";
  token.enteredAt = new Date().toISOString();
  audit("token.entered", `Serial ${token.serial}`);
  showToast("Entered");
  emit();
}

export function markSkipped(tokenId) {
  const token = state.tokens.find((t) => t.id === tokenId);
  if (!token || token.status !== "CALLED") return;
  token.status = "SKIPPED";
  audit("token.skipped", `Serial ${token.serial}`);
  showToast("Marked missed");
  emit();
}

export function openReprint(tokenId) {
  state.ui.modal = { kind: "reprint", tokenId, reason: "" };
  emit();
}

export function confirmReprint(reason) {
  const modal = state.ui.modal;
  if (!modal || modal.kind !== "reprint" || !reason.trim()) return;
  const token = state.tokens.find((t) => t.id === modal.tokenId);
  if (!token) return;
  state.ui.modal = {
    kind: "print-slip",
    tokenId: token.id,
    isReprint: true,
    reason: reason.trim(),
  };
  emit();
  simulatePrint(token.id, {
    isReprint: true,
    onComplete: ({ status, token: view }) => {
      state.ui.modal = {
        kind: "print-slip",
        tokenId: token.id,
        isReprint: true,
        reason: reason.trim(),
        printStatus: status,
        tokenView: view,
      };
      emit();
    },
  });
}

export function openCancel(tokenId, presetReason = "") {
  state.ui.modal = { kind: "cancel", tokenId, reason: presetReason };
  emit();
}

export function confirmCancel(reason) {
  const modal = state.ui.modal;
  if (!modal || modal.kind !== "cancel" || !reason.trim()) return;
  const token = state.tokens.find((t) => t.id === modal.tokenId);
  if (!token) return;
  if (["CALLED", "WAITING", "SKIPPED"].includes(token.status)) {
    token.status = "CANCELLED";
    token.cancelledAt = new Date().toISOString();
    token.cancelReason = reason.trim();
    audit("token.cancelled", `Serial ${token.serial} — ${reason.trim()}`);
  }
  state.ui.modal = null;
  showToast("Token cancelled");
  emit();
}

export function beginWrongQueueFix(tokenId) {
  const token = state.tokens.find((t) => t.id === tokenId);
  if (!token || !["WAITING", "CALLED"].includes(token.status)) return;
  state.ui.modal = {
    kind: "wrong-queue",
    tokenId,
    newQueueTypeId: "",
  };
  emit();
}

export function confirmWrongQueueFix(newQueueTypeId) {
  const modal = state.ui.modal;
  if (!modal || modal.kind !== "wrong-queue" || !newQueueTypeId) return;
  const token = state.tokens.find((t) => t.id === modal.tokenId);
  if (!token || token.queueTypeId === newQueueTypeId) return;

  token.status = "CANCELLED";
  token.cancelledAt = new Date().toISOString();
  token.cancelReason = "WRONG_QUEUE_TYPE";
  audit("token.cancelled", `Serial ${token.serial} — wrong queue`);

  const patient = patientById(token.patientId);
  if (!patient) {
    state.ui.modal = null;
    emit();
    return;
  }

  state.ui.modal = {
    kind: "issue-confirm",
    patientId: patient.id,
    queueTypeId: newQueueTypeId,
    feeBdt: token.feeBdt,
    previewSerial: previewSerial(newQueueTypeId),
    replacedSerial: token.serial,
  };
  emit();
}

export function closeModal() {
  state.ui.modal = null;
  emit();
}

export function openAuditLog() {
  state.ui.modal = { kind: "audit-log" };
  emit();
}

export function waitingMinutesSince(iso, now = Date.now()) {
  const t = new Date(iso).getTime();
  return Math.max(0, Math.floor((now - t) / 60_000));
}

export function formatDurationMinutes(m, locale = "en") {
  if (m < 1) return locale === "bn" ? "১ মি" : "<1 min";
  if (locale === "bn") return `${m} মি`;
  return `${m} min`;
}

export function statusLabel(status) {
  const map = {
    WAITING: "Waiting",
    CALLED: "Called",
    ENTERED: "Entered",
    SKIPPED: "Missed",
    CANCELLED: "Cancelled",
  };
  return map[status] || status;
}

export function queueDisplayName(locale, english, bengali) {
  if (locale === "bn") return bengali || english;
  return english || bengali;
}

/** @deprecated use getSnapshot().queueControls */
export function getQueueControls() {
  return getSnapshot().queueControls.map((c) => ({
    id: c.queueTypeId,
    englishName: c.englishName,
    bengaliName: c.bengaliName,
    waitingCount: c.waitingCount,
    nextSerial: c.nextSerial,
    callNextDisabled: !c.canCallNext,
    recallDisabled: !c.canRecall,
  }));
}

export { QUEUE_TYPES as QUEUE_TYPES_EXPORT };
