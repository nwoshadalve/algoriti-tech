/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { updatePatient } from '@/core/api/patients'
import type { BoardTokenView, PatientSummary } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { BoardDeskPatientFields } from '@/features/board/boardDeskPatientFields'
import { parseDeskNumber } from '@/features/board/boardFormat'
import { PatientDraftNotice } from '@/features/patients/PatientDraftNotice'
import {
  emptyPatientForm,
  usePatientFormDraft,
  type PatientFormValues,
} from '@/features/patients/patientDrafts'
import { formatDigits } from '@/features/queue/formatQueueSerial'
import { FeeField } from '@/features/fees/FeeField'

type PatientEditModalProps = {
  patient: PatientSummary
  /** The patient's token in the open session: when given, its fee can be edited too. */
  feeToken?: BoardTokenView
  onClose: () => void
  onSaved: (patient: PatientSummary) => void
}

function ageFromLabel(label: string | null | undefined): string {
  if (!label) return ''
  return label.replace(/[^\d]/g, '')
}

/** The saved form of a patient. */
export function patientFormOf(patient: PatientSummary): PatientFormValues {
  return {
    ...emptyPatientForm,
    name: patient.name,
    phone: patient.phoneNormalized ? `0${patient.phoneNormalized}` : '',
    age: ageFromLabel(patient.ageLabel),
    gender: patient.gender === 'not_stated' ? '' : (patient.gender ?? ''),
  }
}

/**
 * Edit a patient's name, phone, age and gender, and, in the open session, the
 * fee of their token. What is typed is kept as a draft when the form is closed,
 * until it is saved or discarded.
 */
export function PatientEditModal({ patient, feeToken, onClose, onSaved }: PatientEditModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const draft = usePatientFormDraft(`edit:${patient.id}`, {
    ...patientFormOf(patient),
    feeBdt: feeToken?.feeBdt != null ? String(feeToken.feeBdt) : '',
    isFree: feeToken?.isFree ?? false,
  })
  const { values, setValues } = draft

  async function save() {
    const sessionToken = readSession()
    if (!sessionToken || busy) return
    setSubmitted(true)
    // An empty fee clears it; anything else must be a whole number.
    const fee = parseDeskNumber(values.feeBdt)
    const feeBad =
      Boolean(feeToken) && !values.isFree && values.feeBdt.trim() !== '' && (fee === null || fee < 0)
    if (!values.name.trim() || !values.phone.trim() || feeBad) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setBusy(true)
    try {
      const saved = await updatePatient(sessionToken, patient.id, {
        name: values.name.trim(),
        phone: values.phone.trim(),
        gender: values.gender || undefined,
        approximateAgeYears: parseDeskNumber(values.age) ?? undefined,
        ...(feeToken
          ? {
              tokenId: feeToken.id,
              feeBdt: values.isFree || values.feeBdt.trim() === '' ? null : fee,
              isFree: values.isFree,
            }
          : {}),
      })
      toast.success(t('boardEditPatientSaved'))
      draft.finish()
      onSaved(saved)
    } catch (error) {
      if (error instanceof ApiError && error.code === 'duplicate_phone') {
        toast.error(t('boardErrorDuplicatePhone'))
      } else {
        toast.error(t(boardErrorKey(error)))
      }
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardEditPatientTitle')}
      description={t('boardEditPatientIntro', { id: formatDigits(patient.clinicPatientId, locale) })}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            onClick={() => void save()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('boardEditPatientSave')}
          </LoadingButton>
        </>
      }
    >
      <PatientDraftNotice
        visible={draft.dirty}
        restored={draft.restored}
        onDiscard={draft.discard}
        disabled={busy}
      />
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
      {feeToken ? (
        <FeeField
          id="desk-patient-fee"
          value={values.feeBdt}
          onChange={(feeBdt) => setValues({ feeBdt })}
          disabled={busy}
          error={
            submitted && values.feeBdt.trim() !== '' && parseDeskNumber(values.feeBdt) === null
              ? t('boardFieldRequired')
              : undefined
          }
          free={values.isFree}
          onFreeChange={(isFree) => setValues({ isFree })}
        />
      ) : null}
    </Modal>
  )
}
