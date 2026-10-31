/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState, type FormEvent } from 'react'
import type { QueueTypeConfig } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { TextField } from '@/core/ui/TextField'
import {
  hasQueueTypeFieldErrors,
  validateQueueTypeFields,
  type QueueTypeFieldErrors,
  type QueueTypeFields,
} from '@/features/queue/queueValidation'

type QueueTypeFormModalProps = {
  /** The queue type being edited; omit to add a new one. */
  type?: QueueTypeConfig
  siblings: QueueTypeConfig[]
  onClose: () => void
  /** Returns the full list after add or edit. */
  onSubmitTypes: (types: QueueTypeConfig[]) => Promise<void>
}

const formId = 'queue-type-form'

function fieldsOf(type: QueueTypeConfig | undefined): QueueTypeFields {
  return {
    englishName: type?.englishName ?? '',
    bengaliName: type?.bengaliName ?? '',
    startNumber: type ? String(type.startNumber) : '',
    endNumber: type ? String(type.endNumber) : '',
  }
}

/** Add or edit one queue type in a popup. */
export function QueueTypeFormModal({ type, siblings, onClose, onSubmitTypes }: QueueTypeFormModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const editing = type !== undefined
  const [fields, setFields] = useState<QueueTypeFields>(() => fieldsOf(type))
  const [errors, setErrors] = useState<QueueTypeFieldErrors>({})
  const [busy, setBusy] = useState(false)

  function set<K extends keyof QueueTypeFields>(key: K, value: QueueTypeFields[K]) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found = validateQueueTypeFields(fields, siblings, type?.id)
    setErrors(found)
    if (hasQueueTypeFieldErrors(found)) {
      toast.error(t('errorFixFields'))
      return
    }

    const startNumber = Number(fields.startNumber)
    const endNumber = Number(fields.endNumber)
    const nextType: QueueTypeConfig = {
      id: type?.id ?? `new_${crypto.randomUUID()}`,
      englishName: fields.englishName.trim(),
      bengaliName: fields.bengaliName.trim(),
      startNumber,
      endNumber,
      displayOrder: type?.displayOrder ?? Math.max(0, ...siblings.map((s) => s.displayOrder)) + 1,
      enabled: type?.enabled ?? true,
    }

    const next = editing
      ? siblings.map((row) => (row.id === type.id ? nextType : row))
      : [...siblings, nextType]

    setBusy(true)
    try {
      await onSubmitTypes(next)
    } catch {
      // Toast already shown by the page.
    } finally {
      setBusy(false)
    }
  }

  const error = (key: keyof QueueTypeFields) => {
    const message = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Modal
      title={t(editing ? 'queueTypeEditTitle' : 'queueTypeAddTitle')}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton type="submit" form={formId} isLoading={busy}>
            {t('queueTypeSave')}
          </LoadingButton>
        </>
      }
    >
      <form id={formId} className="grid gap-4 sm:grid-cols-2" onSubmit={(e) => void onSubmit(e)}>
        <TextField
          id="queue-type-en"
          label={t('queueFieldEnglishName')}
          value={fields.englishName}
          error={error('englishName')}
          onChange={(e) => set('englishName', e.target.value)}
          autoComplete="off"
        />
        <TextField
          id="queue-type-bn"
          label={t('queueFieldBengaliName')}
          value={fields.bengaliName}
          error={error('bengaliName')}
          onChange={(e) => set('bengaliName', e.target.value)}
          autoComplete="off"
        />
        <TextField
          id="queue-type-start"
          label={t('queueFieldStart')}
          value={fields.startNumber}
          error={error('startNumber')}
          inputMode="numeric"
          onChange={(e) => set('startNumber', e.target.value)}
          autoComplete="off"
        />
        <TextField
          id="queue-type-end"
          label={t('queueFieldEnd')}
          value={fields.endNumber}
          error={error('endNumber')}
          inputMode="numeric"
          onChange={(e) => set('endNumber', e.target.value)}
          autoComplete="off"
        />
      </form>
    </Modal>
  )
}
