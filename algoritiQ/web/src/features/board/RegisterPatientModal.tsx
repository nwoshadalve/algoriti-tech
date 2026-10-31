/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { registerPatient } from '@/core/api/patients'
import type { PatientGender, PatientSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId } from '@/features/board/boardFormat'

type RegisterPatientModalProps = {
  initialPhone?: string
  confirmDuplicatePhone?: boolean
  onClose: () => void
  onRegistered: (patient: PatientSummary) => void
}

const genderOptions: { value: PatientGender | ''; labelKey: 'boardGenderMale' | 'boardGenderFemale' | 'boardGenderOther' | 'boardGenderNotStated' }[] = [
  { value: 'male', labelKey: 'boardGenderMale' },
  { value: 'female', labelKey: 'boardGenderFemale' },
  { value: 'other', labelKey: 'boardGenderOther' },
  { value: 'not_stated', labelKey: 'boardGenderNotStated' },
]

/** Registers a new clinic patient from the board inline flow. */
export function RegisterPatientModal({
  initialPhone = '',
  confirmDuplicatePhone = false,
  onClose,
  onRegistered,
}: RegisterPatientModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const [bengaliName, setBengaliName] = useState('')
  const [phone, setPhone] = useState(initialPhone)
  const [englishName, setEnglishName] = useState('')
  const [gender, setGender] = useState<PatientGender | ''>('')
  const [locality, setLocality] = useState('')
  const [legacyFileNumber, setLegacyFileNumber] = useState('')
  const [hasPaperFile, setHasPaperFile] = useState(false)

  async function submit() {
    const token = readSession()
    if (!token || busy || !bengaliName.trim() || !phone.trim()) return
    setBusy(true)
    try {
      const patient = await registerPatient(token, {
        commandId: newBoardCommandId(),
        bengaliName: bengaliName.trim(),
        phone: phone.trim(),
        englishName: englishName.trim() || undefined,
        gender: gender || undefined,
        locality: locality.trim() || undefined,
        legacyFileNumber: legacyFileNumber.trim() || undefined,
        hasPaperFile,
        confirmDuplicatePhone,
      })
      toast.success(t('boardPatientRegistered'))
      onRegistered(patient)
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardRegisterTitle')}
      description={confirmDuplicatePhone ? t('boardDuplicatePhoneConfirm') : t('boardRegisterIntro')}
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
            disabled={!bengaliName.trim() || !phone.trim()}
            onClick={() => void submit()}
            className="sm:w-auto sm:min-w-44"
          >
            {t('boardRegisterSave')}
          </LoadingButton>
        </>
      }
    >
      <div className="space-y-4">
        <TextField
          id="reg-bn-name"
          label={t('boardFieldBengaliName')}
          value={bengaliName}
          onChange={(event) => setBengaliName(event.target.value)}
          autoComplete="name"
        />
        <TextField
          id="reg-phone"
          label={t('fieldPhone')}
          value={phone}
          onChange={(event) => setPhone(event.target.value)}
          autoComplete="tel"
        />
        <TextField
          id="reg-en-name"
          label={t('boardFieldEnglishName')}
          value={englishName}
          onChange={(event) => setEnglishName(event.target.value)}
        />
        <SelectField
          id="reg-gender"
          label={t('boardFieldGender')}
          value={gender}
          onChange={(event) => setGender(event.target.value as PatientGender | '')}
          options={[
            { value: '', label: t('boardGenderUnset') },
            ...genderOptions.map((row) => ({ value: row.value, label: t(row.labelKey) })),
          ]}
        />
        <TextField
          id="reg-locality"
          label={t('boardFieldLocality')}
          value={locality}
          onChange={(event) => setLocality(event.target.value)}
        />
        <label className="flex items-start gap-3 text-sm">
          <input
            type="checkbox"
            className="mt-1 h-4 w-4 rounded border-brand-navy/20"
            checked={hasPaperFile}
            onChange={(event) => setHasPaperFile(event.target.checked)}
          />
          <span>{t('boardFieldPaperFile')}</span>
        </label>
        {hasPaperFile ? (
          <TextField
            id="reg-legacy"
            label={t('boardFieldLegacyFile')}
            value={legacyFileNumber}
            onChange={(event) => setLegacyFileNumber(event.target.value)}
          />
        ) : null}
      </div>
    </Modal>
  )
}
