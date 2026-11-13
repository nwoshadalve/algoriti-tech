/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { registerPatient } from '@/core/api/patients'
import type { PatientSummary } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { SelectField } from '@/core/ui/SelectField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { BoardDeskPatientFields } from '@/features/board/boardDeskPatientFields'
import { newBoardCommandId, parseDeskNumber } from '@/features/board/boardFormat'
import { PatientDraftNotice } from '@/features/patients/PatientDraftNotice'
import { emptyPatientForm, usePatientFormDraft } from '@/features/patients/patientDrafts'

type PatientAddModalProps = {
  /** Chambers the patient can be registered in; the first is the default. */
  chambers: { id: string; name: string }[]
  onClose: () => void
  onSaved: (patient: PatientSummary) => void
}

/**
 * Adds a patient from the patient list, without a token. What is typed is kept
 * as a draft when the form is closed, until it is saved or discarded.
 */
export function PatientAddModal({ chambers, onClose, onSaved }: PatientAddModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [duplicateConfirm, setDuplicateConfirm] = useState(false)
  const [chamberId, setChamberId] = useState(chambers[0]?.id ?? '')
  const draft = usePatientFormDraft('page-new', emptyPatientForm)
  const { values, setValues } = draft

  async function save() {
    const token = readSession()
    if (!token || busy) return
    setSubmitted(true)
    if (!values.name.trim() || !values.phone.trim() || !chamberId) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setBusy(true)
    try {
      const saved = await registerPatient(token, {
        commandId: newBoardCommandId(),
        chamberId,
        name: values.name.trim(),
        phone: values.phone.trim(),
        gender: values.gender || undefined,
        approximateAgeYears: parseDeskNumber(values.age) ?? undefined,
        hasPaperFile: values.hasPaperFile,
        confirmDuplicatePhone: duplicateConfirm,
      })
      toast.success(t('patientsSaved'))
      draft.finish()
      onSaved(saved)
    } catch (error) {
      if (error instanceof ApiError && error.code === 'duplicate_phone') {
        setDuplicateConfirm(true)
        toast.error(t('boardErrorDuplicatePhone'))
      } else {
        toast.error(t(boardErrorKey(error)))
      }
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('patientsAddTitle')}
      busy={busy}
      onClose={onClose}
      size="lg"
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            onClick={() => void save()}
            className="sm:w-auto sm:min-w-44"
          >
            {duplicateConfirm ? t('boardRegisterSave') : t('patientsAddSave')}
          </LoadingButton>
        </>
      }
    >
      <PatientDraftNotice
        visible={draft.dirty}
        restored={draft.restored}
        onDiscard={() => {
          draft.discard()
          setSubmitted(false)
          setDuplicateConfirm(false)
        }}
        disabled={busy}
      />
      {duplicateConfirm ? (
        <p className="mb-4 text-sm text-brand-navy/80 dark:text-white/80">
          {t('boardDuplicatePhoneConfirm')}
        </p>
      ) : null}
      <div className="flex flex-col gap-4">
        {chambers.length > 1 ? (
          <SelectField
            id="patient-add-chamber"
            label={t('historyChamber')}
            value={chamberId}
            onChange={(event) => setChamberId(event.target.value)}
            options={chambers.map((c) => ({ value: c.id, label: c.name }))}
            disabled={busy}
          />
        ) : null}
        <BoardDeskPatientFields
          name={values.name}
          phone={values.phone}
          age={values.age}
          gender={values.gender}
          onNameChange={(name) => setValues({ name })}
          onPhoneChange={(phone) => setValues({ phone })}
          onAgeChange={(age) => setValues({ age })}
          onGenderChange={(gender) => setValues({ gender })}
          disabled={busy}
          showErrors={submitted}
        />
        <label className="flex items-start gap-3 text-sm">
          <input
            type="checkbox"
            className="mt-1 h-4 w-4 rounded border-brand-navy/20"
            checked={values.hasPaperFile}
            disabled={busy}
            onChange={(event) => setValues({ hasPaperFile: event.target.checked })}
          />
          <span>{t('boardFieldPaperFile')}</span>
        </label>
      </div>
    </Modal>
  )
}
