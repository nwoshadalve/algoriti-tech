import {
  beginIssuePreview,
  beginWrongQueueFix,
  callNext,
  closeModal,
  confirmCancel,
  confirmIssue,
  confirmReprint,
  confirmWrongQueueFix,
  endSession,
  formatDurationMinutes,
  getSnapshot,
  getState,
  markEntered,
  markSkipped,
  openAuditLog,
  openCancel,
  openEditPatient,
  openPatientEntryModal,
  openRegisterModal,
  openReprint,
  queueDisplayName,
  QUEUE_TYPES,
  recall,
  registerPatient,
  resetDemoData,
  searchPatients,
  selectPatient,
  setPrintSimulation,
  setSearchQuery,
  setFormBind,
  setUi,
  startSession,
  statusLabel,
  subscribe,
  updatePatient,
  waitingMinutesSince,
} from "./board-store.js";
import { getLocale, t } from "./mock-locale.js";

const root = document.getElementById("board-root");
const modalRoot = document.getElementById("board-modal-root");
const toastRoot = document.getElementById("board-toast");

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function formatTime(iso) {
  try {
    return new Date(iso).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  } catch {
    return "";
  }
}

function iconAddPatient() {
  return `<span class="desk-head-btn__glyph" aria-hidden="true"><svg class="desk-head-btn__icon" viewBox="0 0 24 24" fill="currentColor"><path d="M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-1H7v3h3v2H7v3H5v-3H2v-2h3V9h2v2zm4 6.5c-5 0-8.5 2.5-8.5 6v1.5h17V17c0-3.5-3.5-6-8.5-6z"/></svg></span>`;
}

function iconAddExisting() {
  return `<span class="desk-head-btn__glyph" aria-hidden="true"><svg class="desk-head-btn__icon" viewBox="0 0 24 24" fill="currentColor"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg></span>`;
}

function renderSessionPatientActions(snapshot) {
  if (!snapshot.sessionOpen) {
    return "";
  }
  return `<div class="desk-session-head-actions">
    <button type="button" class="desk-head-btn desk-head-btn--primary" data-action="entry-new" title="${escapeHtml(t("deskNewPatientTitle"))}">
      ${iconAddPatient()}<span>${escapeHtml(t("deskAddPatientShort"))}</span>
    </button>
    <button type="button" class="desk-head-btn" data-action="entry-search" title="${escapeHtml(t("deskExistingPatientTitle"))}">
      ${iconAddExisting()}<span>${escapeHtml(t("deskAddExistingShort"))}</span>
    </button>
  </div>`;
}

function renderLeftSessionClosed(snapshot) {
  if (snapshot.sessionOpen) {
    return "";
  }
  return `<section class="desk-card desk-card--muted">
    <p class="desk-card__text">${escapeHtml(t("deskSessionClosedHint"))}</p>
    <button type="button" class="btn btn--primary desk-btn" data-action="start-session">${escapeHtml(t("deskStartSession"))}</button>
  </section>`;
}

function renderPatientEntryModalBody(state) {
  const { ui } = state;
  const snapshot = getSnapshot();
  const results = searchPatients(ui.searchQuery);

  const resultsHtml =
    results.length > 0
      ? `<ul class="desk-search-list" aria-label="Search results">
      ${results
        .map(
          (p) => `<li>
          <button type="button" class="desk-search-list__item" data-action="select-patient" data-patient-id="${p.id}" aria-pressed="${ui.selectedPatientId === p.id}">
            <span class="desk-search-list__name">${escapeHtml(p.bengaliName)}</span>
            <span class="desk-search-list__meta">${escapeHtml(p.clinicPatientId)}${p.ageLabel ? ` · ${escapeHtml(p.ageLabel)}` : ""}</span>
          </button>
        </li>`,
        )
        .join("")}
    </ul>`
      : ui.searchQuery.trim().length >= 2
        ? `<p class="desk-hint">${escapeHtml(t("deskSearchEmpty"))}</p>`
        : "";

  return `
    <div class="field desk-field">
      <label for="patient-search">${escapeHtml(t("deskSearchLabel"))}</label>
      <input id="patient-search" class="desk-input" type="search" autocomplete="off" data-bind="search" value="${escapeHtml(ui.searchQuery)}" placeholder="${escapeHtml(t("deskSearchPlaceholder"))}" />
    </div>
    <p class="desk-hint">${escapeHtml(t("deskSearchHint"))}</p>
    ${resultsHtml}
    <button type="button" class="desk-link" data-action="open-register-from-entry">${escapeHtml(t("deskRegisterLink"))}</button>
    ${snapshot.sessionOpen ? renderPatientTokenForm(state, snapshot, { showIssueButton: true }) : ""}`;
}

function renderGenderOptions(selected) {
  const opts = [
    { value: "", key: "deskGenderNotStated" },
    { value: "male", key: "deskGenderMale" },
    { value: "female", key: "deskGenderFemale" },
    { value: "other", key: "deskGenderOther" },
  ];
  return opts
    .map(
      (o) =>
        `<option value="${o.value}" ${selected === o.value ? "selected" : ""}>${escapeHtml(t(o.key))}</option>`,
    )
    .join("");
}

function renderQueueOptions(snapshot, selectedId) {
  return snapshot.queueControls
    .map((q) => {
      const label = queueDisplayName(getLocale(), q.englishName, q.bengaliName);
      return `<option value="${q.queueTypeId}" ${selectedId === q.queueTypeId ? "selected" : ""}>${escapeHtml(label)}</option>`;
    })
    .join("");
}

/** Patient + token form — required fields marked with * only. */
function renderPatientTokenForm(state, snapshot, options = {}) {
  const { ui } = state;
  const {
    showIssueButton = false,
    submitAction = "",
    submitLabelKey = "deskSaveAndIssue",
    includeQueue = true,
    includeVisitFields = true,
  } = options;

  const queueBlock =
    !includeQueue
      ? ""
      : snapshot.queueControls.length <= 1 && snapshot.queueControls[0]
        ? `<input type="hidden" data-bind="form-queue" value="${snapshot.queueControls[0].queueTypeId}" />
           <p class="desk-queue-chip">${escapeHtml(queueDisplayName(getLocale(), snapshot.queueControls[0].englishName, snapshot.queueControls[0].bengaliName))}</p>`
        : `<div class="field desk-field desk-field--full">
             <label for="form-queue">${escapeHtml(t("deskFieldQueue"))}<span class="desk-req" aria-hidden="true">*</span></label>
             <select id="form-queue" class="desk-input" required data-bind="form-queue">
               <option value="">${escapeHtml(t("deskChooseQueue"))}</option>
               ${renderQueueOptions(snapshot, ui.queueTypeId)}
             </select>
           </div>`;

  const feeField =
    includeQueue && includeVisitFields
      ? `<div class="field desk-field">
           <label for="form-fee">${escapeHtml(t("deskFieldFee"))}</label>
           <input id="form-fee" class="desk-input" type="text" inputmode="numeric" data-bind="form-fee" value="${escapeHtml(ui.feeBdt)}" />
         </div>`
      : "";

  return `
    <div class="desk-form">
      <div class="desk-form__row desk-form__row--2">
        <div class="field desk-field">
          <label for="form-bengali-name">${escapeHtml(t("deskFieldBengaliName"))}<span class="desk-req" aria-hidden="true">*</span></label>
          <input id="form-bengali-name" class="desk-input" type="text" required data-bind="form-bengali-name" value="${escapeHtml(ui.formBengaliName)}" autocomplete="off" />
        </div>
        <div class="field desk-field">
          <label for="form-english-name">${escapeHtml(t("deskFieldEnglishName"))}</label>
          <input id="form-english-name" class="desk-input" type="text" data-bind="form-english-name" value="${escapeHtml(ui.formEnglishName)}" />
        </div>
      </div>
      <div class="field desk-field">
        <label for="form-phone">${escapeHtml(t("deskFieldPhone"))}<span class="desk-req" aria-hidden="true">*</span></label>
        <input id="form-phone" class="desk-input" type="tel" required data-bind="form-phone" value="${escapeHtml(ui.formPhone)}" autocomplete="off" />
      </div>
      ${queueBlock}
      <div class="desk-form__row desk-form__row--3">
        <div class="field desk-field">
          <label for="form-age">${escapeHtml(t("deskFieldAge"))}</label>
          <input id="form-age" class="desk-input" type="text" data-bind="form-age" value="${escapeHtml(ui.formAgeLabel)}" />
        </div>
        <div class="field desk-field">
          <label for="form-gender">${escapeHtml(t("deskFieldGender"))}</label>
          <select id="form-gender" class="desk-input" data-bind="form-gender">${renderGenderOptions(ui.formGender)}</select>
        </div>
        ${feeField}
      </div>
      <label class="desk-check"><input type="checkbox" data-bind="form-paper-file" ${ui.formHasPaperFile ? "checked" : ""} /> ${escapeHtml(t("deskFieldPaperFile"))}</label>
      <div class="field desk-field">
        <label for="form-admin-note">${escapeHtml(t("deskFieldAdminNote"))}</label>
        <input id="form-admin-note" class="desk-input" type="text" data-bind="form-admin-note" value="${escapeHtml(ui.formAdminNote)}" />
      </div>
      ${
        showIssueButton
          ? `<button type="button" class="btn btn--primary desk-btn desk-btn--submit" data-action="issue-preview">${escapeHtml(t("deskReviewPrint"))}</button>`
          : submitAction
            ? `<button type="button" class="btn btn--primary desk-btn desk-btn--submit" data-action="${submitAction}">${escapeHtml(t(submitLabelKey))}</button>`
            : ""
      }
    </div>`;
}

function renderQueueControls(snapshot) {
  const called = snapshot.calledToken;
  const banner = called
    ? `<p class="desk-call-banner" role="status">${called.serial} · ${escapeHtml(t("deskResolveBeforeNext"))}</p>`
    : snapshot.announcementPlaying
      ? `<p class="desk-call-banner" role="status">${escapeHtml(t("deskAnnouncementPlaying"))}</p>`
      : "";

  const list = snapshot.queueControls
    .map((c) => {
      const name = queueDisplayName(getLocale(), c.englishName, c.bengaliName);
      return `<li class="desk-queue-item">
        <div class="desk-queue-item__body">
          <span class="desk-queue-item__name">${escapeHtml(name)}</span>
          <span class="desk-queue-item__meta">${escapeHtml(t("deskQueueWaiting"))} ${c.waitingCount} · ${escapeHtml(t("deskQueueNext"))} ${c.nextSerial}</span>
        </div>
        <div class="desk-queue-item__actions">
          <button type="button" class="btn btn--primary desk-btn desk-btn--sm" data-action="call-next" data-queue-id="${c.queueTypeId}" ${!c.canCallNext ? "disabled" : ""}>${escapeHtml(t("deskCallBtn"))}</button>
          <button type="button" class="btn btn--outline desk-btn desk-btn--sm" data-action="recall" data-queue-id="${c.queueTypeId}" ${!c.canRecall ? "disabled" : ""}>${escapeHtml(t("deskRecallBtn"))}</button>
        </div>
      </li>`;
    })
    .join("");

  return `${banner}<ul class="desk-queue-list">${list}</ul>`;
}

function renderCurrentCall(snapshot) {
  const called = snapshot.calledToken;
  if (!called) {
    return `<div class="desk-call-empty">${escapeHtml(t("deskNoActiveCall"))}</div>`;
  }
  const qName = queueDisplayName(getLocale(), called.queueEnglishName, called.queueBengaliName);
  return `
    <div class="desk-call-panel">
      <div class="desk-call-panel__hero">
        <span class="desk-call-panel__serial">${called.serial}</span>
        <div class="desk-call-panel__text">
          <span class="desk-call-panel__name">${escapeHtml(called.patientBengaliName)}</span>
          <span class="desk-call-panel__meta">${escapeHtml(called.clinicPatientId)} · ${escapeHtml(qName)}</span>
        </div>
      </div>
      <div class="desk-call-panel__actions">
        <button type="button" class="btn btn--outline desk-btn desk-btn--sm" data-action="current-recall">${escapeHtml(t("deskRecallBtn"))}</button>
        <button type="button" class="btn btn--primary desk-btn desk-btn--sm" data-action="current-entered" data-token-id="${called.id}">${escapeHtml(t("deskEnteredBtn"))}</button>
        <button type="button" class="btn btn--outline desk-btn desk-btn--sm" data-action="current-missed" data-token-id="${called.id}">${escapeHtml(t("deskMissedBtn"))}</button>
        <button type="button" class="btn btn--ghost desk-btn desk-btn--sm" data-action="current-cancel" data-token-id="${called.id}">${escapeHtml(t("deskCancelBtn"))}</button>
      </div>
    </div>`;
}

function renderTable(snapshot, state) {
  const tokens = snapshot.tokens;
  const locale = getLocale();
  if (tokens.length === 0) {
    return `<div class="board-empty">No tokens this session</div>`;
  }

  const rows = tokens
    .map((row) => {
      const waiting = waitingMinutesSince(row.issuedAt);
      const printAttention =
        row.latestPrintStatus === "FAILED" || row.latestPrintStatus === "UNKNOWN";
      const printerBusy = state.printerBusyTokenId === row.id;
      const anyPrintBusy = state.printerBusyTokenId != null;
      const qName = queueDisplayName(locale, row.queueEnglishName, row.queueBengaliName);
      let statusText = statusLabel(row.status);
      if (printAttention) statusText += " · not printed";
      if (printerBusy) statusText += " · printing";
      const canFix =
        row.status === "WAITING" || row.status === "CALLED" || row.status === "SKIPPED";
      return `<tr data-status="${row.status}">
        <td class="col-serial">${row.serial}</td>
        <td>${escapeHtml(qName)}</td>
        <td>${escapeHtml(row.clinicPatientId)}</td>
        <td class="col-name">${escapeHtml(row.patientBengaliName)}</td>
        <td>${formatDurationMinutes(waiting, locale)}</td>
        <td>${escapeHtml(statusText)}</td>
        <td class="board-table-actions">
          <button type="button" data-action="reprint" data-token-id="${row.id}" ${anyPrintBusy ? "disabled" : ""} title="Reprint">Print</button>
          ${canFix ? `<button type="button" data-action="row-menu" data-token-id="${row.id}" data-patient-id="${row.patientId}" title="More">⋯</button>` : ""}
        </td>
      </tr>`;
    })
    .join("");

  return `<table class="board-table" aria-label="Session queue">
      <thead>
        <tr>
          <th>#</th>
          <th>Queue</th>
          <th>ID</th>
          <th>Name</th>
          <th>Wait</th>
          <th>Status</th>
          <th></th>
        </tr>
      </thead>
      <tbody>${rows}</tbody>
    </table>`;
}

function renderPrintSlipModal(modal, state) {
  const token =
    modal.tokenView ||
    getSnapshot().tokens.find((t) => t.id === modal.tokenId) ||
    state.tokens.find((t) => t.id === modal.tokenId);
  if (!token) return "";
  const enriched = getSnapshot().tokens.find((t) => t.id === modal.tokenId) || token;
  const qName = queueDisplayName(
    getLocale(),
    enriched.queueEnglishName,
    enriched.queueBengaliName,
  );
  const status = modal.printStatus || enriched.latestPrintStatus || "PENDING";
  const reprintMark = modal.isReprint ? `<p class="board-slip__reprint">REPRINT</p>` : "";
  return `
    <div class="board-modal-scrim" data-action="modal-scrim">
      <div class="board-modal board-modal--slip" role="dialog" aria-modal="true">
        <h2>Token slip</h2>
        <div class="board-slip">
          <p class="board-slip__chamber">${escapeHtml(state.chamberName)}</p>
          <p class="board-slip__serial">${enriched.serial}</p>
          <p class="board-slip__queue">${escapeHtml(qName)}</p>
          <p class="board-slip__id">${escapeHtml(enriched.clinicPatientId)}</p>
          <p class="board-slip__time">${formatTime(enriched.issuedAt)}</p>
          ${reprintMark}
        </div>
        <p class="board-slip__status" data-status="${status}">Print: ${status}</p>
        <div class="board-modal__foot board-modal__foot--single">
          <button type="button" class="btn btn--primary" data-action="modal-close">Done</button>
        </div>
      </div>
    </div>`;
}

function renderModal(state) {
  const modal = state.ui.modal;
  if (!modal) {
    modalRoot.innerHTML = "";
    modalRoot.hidden = true;
    return;
  }
  modalRoot.hidden = false;
  const snapshot = getSnapshot();

  if (modal.kind === "patient-entry") {
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--entry" role="dialog" aria-modal="true" aria-labelledby="desk-modal-existing-title">
          <header class="desk-modal-head">
            <h2 id="desk-modal-existing-title">${escapeHtml(t("deskExistingPatientTitle"))}</h2>
            <button type="button" class="desk-modal-close" data-action="modal-close" aria-label="Close">×</button>
          </header>
          <div class="desk-modal-body">${renderPatientEntryModalBody(state)}</div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "register") {
    const dup = state.ui.duplicateWarning?.length
      ? `<div class="desk-alert">${escapeHtml(t("deskDuplicatePhoneWarn", { ids: state.ui.duplicateWarning.join(", ") }))}</div>`
      : "";
    const submitKey = state.ui.duplicateWarning?.length ? "deskConfirmSaveDuplicate" : "deskSaveAndIssue";
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--entry" role="dialog" aria-modal="true" aria-labelledby="desk-modal-new-title">
          <header class="desk-modal-head">
            <h2 id="desk-modal-new-title">${escapeHtml(t("deskNewPatientTitle"))}</h2>
            <button type="button" class="desk-modal-close" data-action="modal-close" aria-label="Close">×</button>
          </header>
          <div class="desk-modal-body">
            ${dup}
            ${renderPatientTokenForm(state, snapshot, { submitAction: "register-save", submitLabelKey: submitKey })}
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "print-slip") {
    modalRoot.innerHTML = renderPrintSlipModal(modal, state);
    return;
  }

  if (modal.kind === "issue-confirm") {
    const patient = state.patients.find((p) => p.id === modal.patientId);
    const qt = QUEUE_TYPES.find((q) => q.id === modal.queueTypeId);
    const qName = qt
      ? queueDisplayName(getLocale(), qt.englishName, qt.bengaliName)
      : "";
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--wide" role="dialog" aria-modal="true">
          <h2>Confirm token</h2>
          ${modal.replacedSerial ? `<p class="board-panel__hint">Replacing cancelled serial ${modal.replacedSerial}</p>` : ""}
          <dl class="board-confirm-dl">
            <div><dt>Patient</dt><dd>${escapeHtml(patient?.bengaliName ?? "")} · ${escapeHtml(patient?.clinicPatientId ?? "")}</dd></div>
            <div><dt>Queue</dt><dd>${escapeHtml(qName)}</dd></div>
            <div><dt>Preview serial</dt><dd class="preview-serial">${modal.previewSerial}</dd></div>
            ${modal.feeBdt != null ? `<div><dt>Fee</dt><dd>${modal.feeBdt} BDT</dd></div>` : ""}
          </dl>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="issue-back">Back</button>
            <button type="button" class="btn btn--primary" data-action="issue-confirm">Confirm &amp; print</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "active-token") {
    const enriched = snapshot.tokens.find((t) => t.id === modal.tokenId);
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal" role="dialog" aria-modal="true">
          <h2>Active token</h2>
          <p>Token <strong>${enriched?.serial ?? ""}</strong> is already open this session (one per patient).</p>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="issue-back">Back</button>
            <button type="button" class="btn btn--primary" data-action="reprint-from-modal" data-token-id="${enriched?.id ?? ""}">Reprint</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "unresolved-call") {
    const t = snapshot.tokens.find((x) => x.id === modal.tokenId);
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal" role="dialog" aria-modal="true">
          <h2>Resolve current call</h2>
          <p>Serial <strong>${t?.serial ?? ""}</strong> is still called. Mark entered, missed, or cancel before calling next.</p>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="modal-close">Close</button>
            ${t ? `<button type="button" class="btn btn--primary" data-action="current-entered" data-token-id="${t.id}">Patient entered</button>` : ""}
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "row-actions") {
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--menu" role="dialog" aria-modal="true">
          <h2>Token actions</h2>
          <div class="board-action-list">
            <button type="button" data-action="reprint" data-token-id="${modal.tokenId}">Reprint slip</button>
            <button type="button" data-action="wrong-queue" data-token-id="${modal.tokenId}">Wrong queue type…</button>
            <button type="button" data-action="cancel-token" data-token-id="${modal.tokenId}">Cancel token…</button>
            <button type="button" data-action="edit-patient" data-patient-id="${modal.patientId}">Edit patient</button>
          </div>
          <div class="board-modal__foot board-modal__foot--single">
            <button type="button" class="btn btn--outline" data-action="modal-close">Close</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "wrong-queue") {
    const token = state.tokens.find((t) => t.id === modal.tokenId);
    const opts = QUEUE_TYPES.filter((q) => q.id !== token?.queueTypeId)
      .map(
        (q) =>
          `<option value="${q.id}" ${modal.newQueueTypeId === q.id ? "selected" : ""}>${escapeHtml(queueDisplayName(getLocale(), q.englishName, q.bengaliName))}</option>`,
      )
      .join("");
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal" role="dialog" aria-modal="true">
          <h2>Wrong queue type</h2>
          <p>Cancel serial ${token?.serial ?? ""} and issue in the correct queue (serial not reused).</p>
          <div class="field board-field--compact">
            <label>Correct queue</label>
            <select data-modal="wrong-queue-type">
              <option value="">Choose…</option>
              ${opts}
            </select>
          </div>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="modal-close">Back</button>
            <button type="button" class="btn btn--primary" data-action="wrong-queue-confirm">Continue</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "edit-patient") {
    const patient = state.patients.find((p) => p.id === modal.patientId);
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--wide" role="dialog" aria-modal="true">
          <h2>${escapeHtml(t("deskEditPatientTitle"))}</h2>
          <p class="text-small">${escapeHtml(patient?.clinicPatientId ?? "")}</p>
          ${renderPatientTokenForm(state, snapshot, {
            includeQueue: false,
            includeVisitFields: false,
            submitAction: "edit-patient-save",
            submitLabelKey: "settingsSave",
          })}
          <div class="board-modal__foot board-modal__foot--single">
            <button type="button" class="btn btn--outline" data-action="modal-close">Cancel</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "reprint") {
    const token = snapshot.tokens.find((row) => row.id === modal.tokenId);
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal" role="dialog" aria-modal="true">
          <h2>Reprint ${token?.serial ?? ""}</h2>
          <div class="field board-field--compact"><label>Reason</label><input data-modal="reprint-reason" value="${escapeHtml(modal.reason || "")}" /></div>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="modal-close">Cancel</button>
            <button type="button" class="btn btn--primary" data-action="reprint-confirm">Reprint</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "cancel") {
    const token = snapshot.tokens.find((t) => t.id === modal.tokenId);
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal" role="dialog" aria-modal="true">
          <h2>Cancel ${token?.serial ?? ""}</h2>
          <div class="field board-field--compact"><label>Reason</label><input data-modal="cancel-reason" value="${escapeHtml(modal.reason || "")}" placeholder="Required for audit" /></div>
          <div class="board-modal__foot">
            <button type="button" class="btn btn--outline" data-action="modal-close">Back</button>
            <button type="button" class="btn btn--primary" data-action="cancel-confirm">Cancel token</button>
          </div>
        </div>
      </div>`;
    return;
  }

  if (modal.kind === "audit-log") {
    const items = snapshot.auditLog
      .slice(0, 15)
      .map(
        (e) =>
          `<li><time>${formatTime(e.at)}</time> <span>${escapeHtml(e.action)}</span> — ${escapeHtml(e.detail)}</li>`,
      )
      .join("");
    modalRoot.innerHTML = `
      <div class="board-modal-scrim" data-action="modal-scrim">
        <div class="board-modal board-modal--wide" role="dialog" aria-modal="true">
          <h2>Audit log (mock)</h2>
          <ul class="board-audit-list">${items || "<li>No events yet</li>"}</ul>
          <div class="board-modal__foot board-modal__foot--single">
            <button type="button" class="btn btn--outline" data-action="modal-close">Close</button>
          </div>
        </div>
      </div>`;
  }
}

function renderToast(state) {
  const toast = state.ui.toast;
  if (!toast) {
    toastRoot.hidden = true;
    toastRoot.textContent = "";
    return;
  }
  toastRoot.hidden = false;
  toastRoot.className = `board-toast board-toast--${toast.tone === "warn" ? "warn" : "ok"}`;
  toastRoot.textContent = toast.message;
}

function render() {
  const state = getState();
  const snapshot = getSnapshot();
  root.innerHTML = `
    <header class="board-desk-toolbar">
      <label class="board-desk-toolbar__sim">Print sim
        <select data-action="print-sim">
          <option value="success" ${state.printSimulation === "success" ? "selected" : ""}>Success</option>
          <option value="fail" ${state.printSimulation === "fail" ? "selected" : ""}>Fail</option>
          <option value="unknown" ${state.printSimulation === "unknown" ? "selected" : ""}>Unknown</option>
          <option value="random" ${state.printSimulation === "random" ? "selected" : ""}>Random</option>
        </select>
      </label>
      <span class="board-desk-toolbar__session">${snapshot.sessionOpen ? escapeHtml(t("deskSessionOpen")) : escapeHtml(t("deskSessionClosed"))}</span>
      <button type="button" class="board-desk-toolbar__link" data-action="open-audit">Audit</button>
      <button type="button" class="board-desk-toolbar__link" data-action="toggle-session">${snapshot.sessionOpen ? escapeHtml(t("deskEndSession")) : escapeHtml(t("deskStartSession"))}</button>
      <button type="button" class="board-desk-toolbar__link" data-action="reset-demo">Reset</button>
    </header>
    <div class="board-desk-columns">
      <aside class="board-desk-left" aria-label="${escapeHtml(t("deskSectionQueues"))}">
        ${renderLeftSessionClosed(snapshot)}
        <section class="desk-card">
          <h2 class="desk-section-title">${escapeHtml(t("deskNowCalling"))}</h2>
          ${renderCurrentCall(snapshot)}
        </section>
        <section class="desk-card desk-card--grow">
          <h2 class="desk-section-title">${escapeHtml(t("deskSectionQueues"))}</h2>
          ${renderQueueControls(snapshot)}
        </section>
      </aside>
      <section class="board-desk-session" aria-label="${escapeHtml(t("deskSectionSession"))}">
        <header class="board-desk-session__head">
          <h2 class="desk-section-title">${escapeHtml(t("deskSectionSession"))}</h2>
          ${renderSessionPatientActions(snapshot)}
        </header>
        <div class="board-table-wrap">${renderTable(snapshot, state)}</div>
      </section>
    </div>`;
  renderModal(state);
  renderToast(state);
}

function onClick(event) {
  const target = event.target.closest("[data-action]");
  if (!target) return;
  const action = target.getAttribute("data-action");
  const snapshot = getSnapshot();

  switch (action) {
    case "start-session":
      startSession();
      break;
    case "toggle-session":
      if (getSnapshot().sessionOpen) endSession();
      else startSession();
      break;
    case "entry-new":
      openRegisterModal("");
      break;
    case "entry-search":
      openPatientEntryModal();
      break;
    case "open-register-from-entry":
      openRegisterModal(getState().ui.searchQuery.trim());
      break;
    case "select-patient":
      selectPatient(target.getAttribute("data-patient-id"));
      break;
    case "issue-preview":
      beginIssuePreview();
      break;
    case "call-next":
      callNext(target.getAttribute("data-queue-id"));
      break;
    case "recall":
      recall(target.getAttribute("data-queue-id"));
      break;
    case "current-recall":
      if (snapshot.calledToken) recall(snapshot.calledToken.queueTypeId);
      break;
    case "current-entered":
      markEntered(target.getAttribute("data-token-id"));
      closeModal();
      break;
    case "current-missed":
      markSkipped(target.getAttribute("data-token-id"));
      break;
    case "current-cancel":
      openCancel(target.getAttribute("data-token-id"));
      break;
    case "reprint":
      closeModal();
      openReprint(target.getAttribute("data-token-id"));
      break;
    case "reprint-from-modal":
      closeModal();
      openReprint(target.getAttribute("data-token-id"));
      break;
    case "cancel-token":
      closeModal();
      openCancel(target.getAttribute("data-token-id"));
      break;
    case "row-menu":
      setUi({
        modal: {
          kind: "row-actions",
          tokenId: target.getAttribute("data-token-id"),
          patientId: target.getAttribute("data-patient-id"),
        },
      });
      break;
    case "wrong-queue":
      closeModal();
      beginWrongQueueFix(target.getAttribute("data-token-id"));
      break;
    case "wrong-queue-confirm": {
      const sel = modalRoot.querySelector("[data-modal=wrong-queue-type]");
      const v = sel instanceof HTMLSelectElement ? sel.value : "";
      confirmWrongQueueFix(v);
      break;
    }
    case "edit-patient":
      closeModal();
      openEditPatient(target.getAttribute("data-patient-id"));
      break;
    case "edit-patient-save": {
      const m = getState().ui.modal;
      if (!m || m.kind !== "edit-patient") return;
      const ui = getState().ui;
      updatePatient(m.patientId, {
        bengaliName: ui.formBengaliName,
        phone: ui.formPhone,
        englishName: ui.formEnglishName,
        ageLabel: ui.formAgeLabel,
        gender: ui.formGender,
        adminNote: ui.formAdminNote,
        hasPaperFile: ui.formHasPaperFile,
      });
      closeModal();
      break;
    }
    case "issue-back":
      setUi({ modal: { kind: "patient-entry" } });
      break;
    case "modal-close":
    case "modal-scrim":
      if (action === "modal-scrim" && event.target !== target) return;
      closeModal();
      break;
    case "issue-confirm":
      confirmIssue();
      break;
    case "register-save": {
      const ui = getState().ui;
      registerPatient({
        bengaliName: ui.formBengaliName,
        phone: ui.formPhone,
        englishName: ui.formEnglishName,
        approxAge: ui.formAgeLabel,
        gender: ui.formGender,
        hasPaperFile: ui.formHasPaperFile,
        adminNote: ui.formAdminNote,
        queueTypeId: ui.queueTypeId,
        feeBdt: ui.feeBdt,
        confirmDuplicatePhone: Boolean(ui.duplicateWarning?.length),
      });
      break;
    }
    case "reprint-confirm": {
      const input = modalRoot.querySelector("[data-modal=reprint-reason]");
      confirmReprint(input instanceof HTMLInputElement ? input.value : "");
      break;
    }
    case "cancel-confirm": {
      const input = modalRoot.querySelector("[data-modal=cancel-reason]");
      confirmCancel(input instanceof HTMLInputElement ? input.value : "");
      break;
    }
    case "open-audit":
      openAuditLog();
      break;
    case "reset-demo":
      if (window.confirm("Reset queue desk demo data?")) resetDemoData();
      break;
    default:
      break;
  }
}

function onChange(event) {
  const el = event.target;
  if (!(el instanceof HTMLSelectElement)) return;
  if (el.getAttribute("data-action") === "print-sim") {
    setPrintSimulation(el.value);
  }
}

function onInput(event) {
  const el = event.target;
  if (!(el instanceof HTMLInputElement || el instanceof HTMLSelectElement)) return;
  const bind = el.getAttribute("data-bind");
  if (!bind) return;
  if (el instanceof HTMLInputElement && el.type === "checkbox") {
    setFormBind(bind, el.checked);
    return;
  }
  setFormBind(bind, el.value);
}

function onChangeForm(event) {
  const el = event.target;
  if (el instanceof HTMLSelectElement && el.getAttribute("data-bind")) {
    setFormBind(el.getAttribute("data-bind"), el.value);
  }
}

if (root && modalRoot && toastRoot) {
  root.addEventListener("click", onClick);
  root.addEventListener("change", onChange);
  modalRoot.addEventListener("click", onClick);
  root.addEventListener("input", onInput);
  modalRoot.addEventListener("input", onInput);
  modalRoot.addEventListener("change", onChangeForm);

  window.addEventListener("mock-locale-change", render);

  subscribe(render);
  render();

  window.setInterval(() => {
    if (getState().ui.modal?.kind === "print-slip") return;
    if (getState().ui.modal) return;
    render();
  }, 60_000);
}
