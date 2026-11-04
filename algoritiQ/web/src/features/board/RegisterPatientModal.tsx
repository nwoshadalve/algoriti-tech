/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { registerAndIssueToken } from '@/core/api/queueDesk'
import type { PatientGender, QueueTypeBoardControl } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, parseDeskNumber } from '@/features/board/boardFormat'
import { BoardDeskPatientFields } from '@/features/board/boardDeskPatientFields'
import { afterDeskIssue } from '@/features/board/deskAfterIssue'
import { QueueDeskQueuePicker } from '@/features/board/QueueDeskQueuePicker'

type RegisterPatientModalProps = {
  initialPhone?: string
  initialName?: string
  chamberId: string
  queueControls: QueueTypeBoardControl[]
  onClose: () => void
  onDone: () => void | Promise<void>
}

const bengaliRe = /[ঀ-৿]/

/** Registers a new patient and issues a token in one step (tablet desk flow). */
export function RegisterPatientModal({
  initialPhone = '',
  initialName = '',
  chamberId,
  queueControls,
  onClose,
  onDone,
}: RegisterPatientModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [bengaliName, setBengaliName] = useState(() =>
    bengaliRe.test(initialName) ? initialName : '',
  )
  const [phone, setPhone] = useState(initialPhone)
  const [englishName, setEnglishName] = useState(() =>
    initialName && !bengaliRe.test(initialName) ? initialName : '',
  )
  const [gender, setGender] = useState<PatientGender | ''>('')
  const [ageLabel, setAgeLabel] = useState('')
  const [hasPaperFile, setHasPaperFile] = useState(false)
  const [queueTypeId, setQueueTypeId] = useState('')
  const [feeBdt, setFeeBdt] = useState('')
  const [duplicateConfirm, setDuplicateConfirm] = useState(false)

  useEffect(() => {
    if (queueControls.length === 1) {
      setQueueTypeId(queueControls[0]!.queueTypeId)
    }
  }, [queueControls])

  const valid = Boolean(bengaliName.trim() && phone.trim() && queueTypeId)

  async function submit() {
    const token = readSession()
    if (!token || busy) return
    setSubmitted(true)
    if (!valid) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setBusy(true)
    const fee = parseDeskNumber(feeBdt)
    try {
      const issued = await registerAndIssueToken(token, chamberId, {
        commandId: newBoardCommandId(),
        chamberId,
        bengaliName: bengaliName.trim(),
        phone: phone.trim(),
        englishName: englishName.trim() || undefined,
        gender: gender || undefined,
        approximateAgeYears: parseDeskNumber(ageLabel) ?? undefined,
        hasPaperFile,
        confirmDuplicatePhone: duplicateConfirm,
        queueTypeId,
        feeBdt: fee,
      })
      onClose()
      await afterDeskIssue(issued, onDone, toast, t)
    } catch (error) {
      if (error instanceof ApiError && error.code === 'duplicate_phone') {
        setDuplicateConfirm(true)
        toast.error(t('boardErrorDuplicatePhone'))
      } else {
        toast.error(t(boardErrorKey(error)))
      }
    } finally {
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('boardRegisterTitle')}
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
            onClick={() => void submit()}
            className="sm:w-auto sm:min-w-44"
          >
            {duplicateConfirm ? t('boardRegisterSave') : t('boardSaveAndIssue')}
          </LoadingButton>
        </>
      }
    >
      {duplicateConfirm ? (
        <p className="mb-4 text-sm text-brand-navy/80 dark:text-white/80">
          {t('boardDuplicatePhoneConfirm')}
        </p>
      ) : null}
      <BoardDeskPatientFields
        bengaliName={bengaliName}
        englishName={englishName}
        phone={phone}
        age={ageLabel}
        gender={gender}
        onBengaliNameChange={setBengaliName}
        onEnglishNameChange={setEnglishName}
        onPhoneChange={setPhone}
        onAgeChange={setAgeLabel}
        onGenderChange={setGender}
        disabled={busy}
        showErrors={submitted}
      />
      <div className="mt-4">
        <QueueDeskQueuePicker
          controls={queueControls}
          selectedId={queueTypeId || null}
          onSelected={setQueueTypeId}
          disabled={busy}
          errorText={submitted && !queueTypeId ? t('boardFieldRequired') : undefined}
        />
      </div>
      <div className="mt-4">
        <TextField
          id="reg-fee"
          label={t('boardFieldFee')}
          inputMode="numeric"
          value={feeBdt}
          onChange={(event) => setFeeBdt(event.target.value)}
          disabled={busy}
        />
      </div>
      <label className="mt-4 flex items-start gap-3 text-sm">
        <input
          type="checkbox"
          className="mt-1 h-4 w-4 rounded border-brand-navy/20"
          checked={hasPaperFile}
          disabled={busy}
          onChange={(event) => setHasPaperFile(event.target.checked)}
        />
        <span>{t('boardFieldPaperFile')}</span>
      </label>
    </Modal>
  )
}
