/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { registerAndIssueToken } from '@/core/api/queueDesk'
import type { QueueTypeBoardControl } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { newBoardCommandId, parseDeskNumber } from '@/features/board/boardFormat'
import { BoardDeskPatientFields } from '@/features/board/boardDeskPatientFields'
import { afterDeskIssue } from '@/features/board/deskAfterIssue'
import { QueueDeskQueuePicker } from '@/features/board/QueueDeskQueuePicker'
import { PatientDraftNotice } from '@/features/patients/PatientDraftNotice'
import {
  emptyPatientForm,
  usePatientFormDraft,
  type PatientFormValues,
} from '@/features/patients/patientDrafts'
import { FeeField } from '@/features/fees/FeeField'

type RegisterPatientModalProps = {
  initialPhone?: string
  initialName?: string
  chamberId: string
  queueControls: QueueTypeBoardControl[]
  onClose: () => void
  onDone: () => void | Promise<void>
}


/**
 * Registers a new patient and issues a token in one step (tablet desk flow).
 * What is typed is kept as a draft when the form is closed, until it is
 * saved or discarded.
 */
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
  const [duplicateConfirm, setDuplicateConfirm] = useState(false)

  const [baseline] = useState<PatientFormValues>(() => ({
    ...emptyPatientForm,
    name: initialName,
    phone: initialPhone,
    queueTypeId: queueControls.length === 1 ? queueControls[0]!.queueTypeId : '',
  }))
  // A draft comes back unless the desk opened this form for a typed search.
  const draft = usePatientFormDraft(`desk-new:${chamberId}`, baseline, {
    ignoreDraft: Boolean(initialPhone || initialName),
  })
  const { values, setValues } = draft

  useEffect(() => {
    if (queueControls.length === 1 && !values.queueTypeId) {
      setValues({ queueTypeId: queueControls[0]!.queueTypeId })
    }
  }, [queueControls, values.queueTypeId, setValues])

  const valid = Boolean(values.name.trim() && values.phone.trim() && values.queueTypeId)

  async function submit() {
    const token = readSession()
    if (!token || busy) return
    setSubmitted(true)
    if (!valid) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setBusy(true)
    try {
      const issued = await registerAndIssueToken(token, chamberId, {
        commandId: newBoardCommandId(),
        chamberId,
        name: values.name.trim(),
        phone: values.phone.trim(),
        gender: values.gender || undefined,
        approximateAgeYears: parseDeskNumber(values.age) ?? undefined,
        hasPaperFile: values.hasPaperFile,
        confirmDuplicatePhone: duplicateConfirm,
        queueTypeId: values.queueTypeId,
        feeBdt: values.isFree ? null : parseDeskNumber(values.feeBdt),
        isFree: values.isFree,
      })
      draft.finish()
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
      <div className="mt-4">
        <QueueDeskQueuePicker
          controls={queueControls}
          selectedId={values.queueTypeId || null}
          onSelected={(queueTypeId) => setValues({ queueTypeId })}
          disabled={busy}
          errorText={submitted && !values.queueTypeId ? t('boardFieldRequired') : undefined}
        />
      </div>
      <div className="mt-4">
        <FeeField
          id="reg-fee"
          value={values.feeBdt}
          onChange={(feeBdt) => setValues({ feeBdt })}
          disabled={busy}
          free={values.isFree}
          onFreeChange={(isFree) => setValues({ isFree })}
        />
      </div>
      <label className="mt-4 flex items-start gap-3 text-sm">
        <input
          type="checkbox"
          className="mt-1 h-4 w-4 rounded border-brand-navy/20"
          checked={values.hasPaperFile}
          disabled={busy}
          onChange={(event) => setValues({ hasPaperFile: event.target.checked })}
        />
        <span>{t('boardFieldPaperFile')}</span>
      </label>
    </Modal>
  )
}
