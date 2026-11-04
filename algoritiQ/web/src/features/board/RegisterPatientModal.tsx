/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { previewIssueToken } from '@/core/api/queueDesk'
import { registerPatient } from '@/core/api/patients'
import type { PatientGender, QueueTypeBoardControl } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, queueDisplayName } from '@/features/board/boardFormat'
import { IssueConfirmModal } from '@/features/board/IssueConfirmModal'

type RegisterPatientModalProps = {
  initialPhone?: string
  confirmDuplicatePhone?: boolean
  chamberId: string
  queueControls: QueueTypeBoardControl[]
  onClose: () => void
  onRegistered: () => void
}

const genderOptions: {
  value: PatientGender | ''
  labelKey: 'boardGenderMale' | 'boardGenderFemale' | 'boardGenderOther' | 'boardGenderNotStated'
}[] = [
  { value: 'male', labelKey: 'boardGenderMale' },
  { value: 'female', labelKey: 'boardGenderFemale' },
  { value: 'other', labelKey: 'boardGenderOther' },
  { value: 'not_stated', labelKey: 'boardGenderNotStated' },
]

/** Registers a new patient and continues to token issue. */
export function RegisterPatientModal({
  initialPhone = '',
  confirmDuplicatePhone = false,
  chamberId,
  queueControls,
  onClose,
  onRegistered,
}: RegisterPatientModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const [bengaliName, setBengaliName] = useState('')
  const [phone, setPhone] = useState(initialPhone)
  const [englishName, setEnglishName] = useState('')
  const [gender, setGender] = useState<PatientGender | ''>('')
  const [ageLabel, setAgeLabel] = useState('')
  const [adminNote, setAdminNote] = useState('')
  const [hasPaperFile, setHasPaperFile] = useState(false)
  const [queueTypeId, setQueueTypeId] = useState('')
  const [feeBdt, setFeeBdt] = useState('')
  const [issuePreview, setIssuePreview] = useState<Awaited<ReturnType<typeof previewIssueToken>> | null>(
    null,
  )
  const [needsDuplicateConfirm, setNeedsDuplicateConfirm] = useState(confirmDuplicatePhone)

  const enabledTypes = queueControls
  const defaultQueueId = enabledTypes.length === 1 ? enabledTypes[0]!.queueTypeId : queueTypeId

  useEffect(() => {
    if (enabledTypes.length === 1) {
      setQueueTypeId(enabledTypes[0]!.queueTypeId)
    }
  }, [enabledTypes])

  const queueOptions = enabledTypes.map((row) => ({
    value: row.queueTypeId,
    label: queueDisplayName(locale, row.englishName, row.bengaliName),
  }))

  async function submit(confirmDuplicate: boolean) {
    const token = readSession()
    if (!token || busy || !bengaliName.trim() || !phone.trim() || !defaultQueueId) return
    setBusy(true)
    const ageNum = ageLabel.trim() ? Number.parseInt(ageLabel.trim(), 10) : NaN
    try {
      const patient = await registerPatient(token, {
        commandId: newBoardCommandId(),
        chamberId,
        bengaliName: bengaliName.trim(),
        phone: phone.trim(),
        englishName: englishName.trim() || undefined,
        gender: gender || undefined,
        approximateAgeYears: Number.isFinite(ageNum) ? ageNum : undefined,
        adminNote: adminNote.trim() || undefined,
        hasPaperFile,
        confirmDuplicatePhone: confirmDuplicate,
      })
      const fee = feeBdt.trim() ? Number(feeBdt) : undefined
      const preview = await previewIssueToken(token, chamberId, patient.id, defaultQueueId, fee)
      setIssuePreview(preview)
      setNeedsDuplicateConfirm(false)
    } catch (error) {
      if (error instanceof ApiError && error.code === 'duplicate_phone_needs_confirm') {
        setNeedsDuplicateConfirm(true)
        toast.error(t('boardErrorDuplicatePhone'))
      } else {
        toast.error(t(boardErrorKey(error)))
      }
      setBusy(false)
    }
  }

  if (issuePreview) {
    return (
      <IssueConfirmModal
        chamberId={chamberId}
        preview={issuePreview}
        onClose={() => {
          setIssuePreview(null)
          setBusy(false)
        }}
        onIssued={() => {
          toast.success(t('boardPatientRegistered'))
          onRegistered()
        }}
      />
    )
  }

  return (
    <Modal
      title={t('boardRegisterTitle')}
      description={
        needsDuplicateConfirm ? t('boardDuplicatePhoneConfirm') : t('boardRegisterIntro')
      }
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
            disabled={!bengaliName.trim() || !phone.trim() || !defaultQueueId}
            onClick={() => void submit(needsDuplicateConfirm)}
            className="sm:w-auto sm:min-w-44"
          >
            {needsDuplicateConfirm ? t('boardRegisterSave') : t('boardSaveAndIssue')}
          </LoadingButton>
        </>
      }
    >
      <div className="grid gap-4 sm:grid-cols-2">
        <TextField
          id="reg-bn-name"
          label={`${t('boardFieldBengaliName')} *`}
          value={bengaliName}
          onChange={(event) => setBengaliName(event.target.value)}
          autoComplete="name"
          className="sm:col-span-1"
        />
        <TextField
          id="reg-en-name"
          label={t('boardFieldEnglishName')}
          value={englishName}
          onChange={(event) => setEnglishName(event.target.value)}
        />
        <TextField
          id="reg-phone"
          label={`${t('fieldPhone')} *`}
          value={phone}
          onChange={(event) => setPhone(event.target.value)}
          autoComplete="tel"
          className="sm:col-span-2"
        />
        {enabledTypes.length > 1 ? (
          <SelectField
            id="reg-queue"
            label={`${t('boardFieldQueue')} *`}
            value={queueTypeId}
            onChange={(event) => setQueueTypeId(event.target.value)}
            options={[{ value: '', label: t('boardChooseQueue') }, ...queueOptions]}
            className="sm:col-span-2"
          />
        ) : enabledTypes[0] ? (
          <p className="sm:col-span-2 rounded-xl bg-brand-mist/80 px-3 py-2 text-sm font-medium dark:bg-white/10">
            {queueDisplayName(locale, enabledTypes[0].englishName, enabledTypes[0].bengaliName)}
          </p>
        ) : null}
        <TextField
          id="reg-age"
          label={t('boardFieldAge')}
          value={ageLabel}
          onChange={(event) => setAgeLabel(event.target.value)}
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
          id="reg-fee"
          label={t('boardFieldFee')}
          inputMode="numeric"
          value={feeBdt}
          onChange={(event) => setFeeBdt(event.target.value)}
        />
        <TextField
          id="reg-admin-note"
          label={t('boardFieldAdminNote')}
          value={adminNote}
          onChange={(event) => setAdminNote(event.target.value)}
          className="sm:col-span-2"
        />
        <label className="flex items-start gap-3 text-sm sm:col-span-2">
          <input
            type="checkbox"
            className="mt-1 h-4 w-4 rounded border-brand-navy/20"
            checked={hasPaperFile}
            onChange={(event) => setHasPaperFile(event.target.checked)}
          />
          <span>{t('boardFieldPaperFile')}</span>
        </label>
      </div>
    </Modal>
  )
}
