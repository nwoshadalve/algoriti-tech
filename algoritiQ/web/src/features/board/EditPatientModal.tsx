/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { searchPatients, updatePatient } from '@/core/api/patients'
import type { BoardTokenView, PatientGender, PatientSummary } from '@/core/api/types'
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

type EditPatientModalProps = {
  token: BoardTokenView
  initialPatient?: PatientSummary
  onClose: () => void
  onSaved: (patient?: PatientSummary) => void
}

function ageFromLabel(label: string | null | undefined): string {
  if (!label) return ''
  return label.replace(/[^\d]/g, '')
}

/** Edit patient profile fields allowed from the queue desk (tablet field set). */
export function EditPatientModal({
  token,
  initialPatient,
  onClose,
  onSaved,
}: EditPatientModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [loading, setLoading] = useState(!initialPatient)
  const [busy, setBusy] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [bengaliName, setBengaliName] = useState(initialPatient?.bengaliName ?? token.patientBengaliName)
  const [phone, setPhone] = useState(
    initialPatient?.phoneNormalized ? `0${initialPatient.phoneNormalized}` : '',
  )
  const [englishName, setEnglishName] = useState(initialPatient?.englishName ?? '')
  const [age, setAge] = useState(ageFromLabel(initialPatient?.ageLabel))
  const [gender, setGender] = useState<PatientGender | ''>(initialPatient?.gender ?? '')

  useEffect(() => {
    if (initialPatient) return
    const sessionToken = readSession()
    if (!sessionToken) {
      setLoading(false)
      return
    }
    void searchPatients(sessionToken, token.clinicPatientId)
      .then((rows) => {
        const match = rows.find((row) => row.id === token.patientId) ?? rows[0]
        if (match) {
          setBengaliName(match.bengaliName)
          setPhone(match.phoneNormalized ? `0${match.phoneNormalized}` : '')
          setEnglishName(match.englishName ?? '')
          setAge(ageFromLabel(match.ageLabel))
          setGender(match.gender ?? '')
        }
      })
      .finally(() => setLoading(false))
  }, [initialPatient, token.clinicPatientId, token.patientId])

  async function save() {
    const sessionToken = readSession()
    if (!sessionToken || busy) return
    setSubmitted(true)
    if (!bengaliName.trim() || !phone.trim()) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setBusy(true)
    try {
      const saved = await updatePatient(sessionToken, token.patientId, {
        bengaliName: bengaliName.trim(),
        phone: phone.trim(),
        englishName: englishName.trim() || undefined,
        gender: gender || undefined,
        approximateAgeYears: parseDeskNumber(age) ?? undefined,
      })
      toast.success(t('boardEditPatientSaved'))
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
      description={t('boardEditPatientIntro', { id: token.clinicPatientId })}
      busy={busy || loading}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            disabled={loading}
            onClick={() => void save()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('boardEditPatientSave')}
          </LoadingButton>
        </>
      }
    >
      <BoardDeskPatientFields
        bengaliName={bengaliName}
        englishName={englishName}
        phone={phone}
        age={age}
        gender={gender}
        onBengaliNameChange={setBengaliName}
        onEnglishNameChange={setEnglishName}
        onPhoneChange={setPhone}
        onAgeChange={setAge}
        onGenderChange={setGender}
        disabled={busy || loading}
        showErrors={submitted}
      />
    </Modal>
  )
}
