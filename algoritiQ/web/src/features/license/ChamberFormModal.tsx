/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState, type FormEvent } from 'react'
import { createChamber, updateChamber } from '@/core/api/chambers'
import type { Chamber, ChamberInput } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { chamberError } from '@/features/license/chamberErrors'
import { validateChamber, type ChamberErrors } from '@/features/license/chamberValidation'

type ChamberFormModalProps = {
  /** The chamber being edited; omit to add a new one. */
  chamber?: Chamber
  onClose: () => void
  onSaved: (chamber: Chamber, created: boolean) => void
  /** The tablet said the license is full: the page should look again. */
  onLimit: () => void
}

const formId = 'chamber-form'

/** One popup for adding a chamber and editing one. */
export function ChamberFormModal({ chamber, onClose, onSaved, onLimit }: ChamberFormModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const editing = chamber !== undefined
  const [fields, setFields] = useState<ChamberInput>({
    name: chamber?.name ?? '',
    location: chamber?.location ?? '',
    phone: chamber?.phone ?? '',
  })
  const [errors, setErrors] = useState<ChamberErrors>({})
  const [busy, setBusy] = useState(false)

  function set(key: keyof ChamberInput, value: string) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found = validateChamber(fields)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token) return

    setBusy(true)
    const input = {
      name: fields.name.trim(),
      location: fields.location.trim(),
      phone: fields.phone.trim(),
    }
    try {
      const saved = editing
        ? await updateChamber(token, chamber.id, input)
        : await createChamber(token, input)
      toast.success(t(editing ? 'chamberSaved' : 'chamberAdded'))
      onSaved(saved, !editing)
    } catch (error) {
      const { key, field } = chamberError(error)
      if (field) setErrors({ [field]: key })
      if (key === 'chamberErrorLimit') onLimit()
      toast.error(t(key))
      setBusy(false)
    }
  }

  const error = (key: keyof ChamberInput) => {
    const message = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Modal
      title={t(editing ? 'chamberEditTitle' : 'chamberAddTitle')}
      description={t('chamberFormIntro')}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            type="submit"
            form={formId}
            isLoading={busy}
            loadingLabel={t('usersSaving')}
            className="sm:w-auto sm:min-w-40"
          >
            {editing ? t('usersSave') : t('chambersAdd')}
          </LoadingButton>
        </>
      }
    >
      <form id={formId} className="space-y-5" onSubmit={(event) => void onSubmit(event)} noValidate>
        <TextField
          id="chamber-name"
          label={t('fieldChamberName')}
          autoComplete="off"
          value={fields.name}
          error={error('name')}
          onChange={(event) => set('name', event.target.value)}
        />
        <TextField
          id="chamber-address"
          label={t('fieldChamberAddress')}
          autoComplete="off"
          value={fields.location}
          error={error('location')}
          onChange={(event) => set('location', event.target.value)}
        />
        <TextField
          id="chamber-phone"
          label={t('fieldChamberPhone')}
          hint={t('fieldChamberPhoneHint')}
          type="tel"
          autoComplete="off"
          value={fields.phone}
          error={error('phone')}
          onChange={(event) => set('phone', event.target.value)}
        />
      </form>
    </Modal>
  )
}
