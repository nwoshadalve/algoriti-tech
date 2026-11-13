/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { searchPatients } from '@/core/api/patients'
import type { BoardTokenView, PatientSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { Modal } from '@/core/ui/Modal'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { readSession } from '@/features/auth/session'
import { PatientEditModal } from '@/features/patients/PatientEditModal'

type EditPatientModalProps = {
  token: BoardTokenView
  /** The token is a real one of the open session, so its fee can be edited. */
  withFee?: boolean
  initialPatient?: PatientSummary
  onClose: () => void
  onSaved: (patient?: PatientSummary) => void
}

/**
 * Edit the patient of a queue token. The patient is looked up first when the
 * desk does not have them; the form itself (with its draft) is the shared one.
 */
export function EditPatientModal({ token, withFee, initialPatient, onClose, onSaved }: EditPatientModalProps) {
  const { t } = useLocale()
  const [patient, setPatient] = useState<PatientSummary | null>(initialPatient ?? null)

  useEffect(() => {
    if (initialPatient) return
    const sessionToken = readSession()
    if (!sessionToken) return
    let cancelled = false
    // Without the full record the form still opens, with what the token knows.
    const fallback: PatientSummary = {
      id: token.patientId,
      patientNumber: 0,
      clinicPatientId: token.clinicPatientId,
      name: token.patientName,
      phoneNormalized: '',
    }
    void searchPatients(sessionToken, token.clinicPatientId)
      .then((rows) => rows.find((row) => row.id === token.patientId) ?? rows[0] ?? fallback)
      .catch(() => fallback)
      .then((match) => {
        if (!cancelled) setPatient(match)
      })
    return () => {
      cancelled = true
    }
  }, [initialPatient, token.clinicPatientId, token.patientId, token.patientName])

  if (!patient) {
    return (
      <Modal title={t('boardEditPatientTitle')} busy onClose={onClose}>
        <PagePreloader />
      </Modal>
    )
  }
  return (
    <PatientEditModal
      patient={patient}
      feeToken={withFee ? token : undefined}
      onClose={onClose}
      onSaved={onSaved}
    />
  )
}
