/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState, type FormEvent } from 'react'
import { ApiError } from '@/core/api/client'
import { setUserPassword } from '@/core/api/users'
import type { ManagedUser } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { PasswordField } from '@/core/ui/PasswordField'
import { readSession } from '@/features/auth/session'
import { usersErrorKey } from '@/features/users/usersErrorMessages'
import {
  hasFieldErrors,
  validateSetPassword,
  type FieldErrors,
  type SetPasswordFields,
} from '@/features/users/userValidation'

const formId = 'set-user-password-form'

const apiField: Partial<Record<string, keyof SetPasswordFields>> = {
  password_too_short: 'password',
  password_too_long: 'password',
  password_contains_username: 'password',
}

type SetUserPasswordModalProps = {
  user: ManagedUser
  onClose: () => void
  onSaved: () => void
}

/** Lets an admin choose a new sign-in password for someone else. */
export function SetUserPasswordModal({ user, onClose, onSaved }: SetUserPasswordModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [fields, setFields] = useState<SetPasswordFields>({ password: '', confirmPassword: '' })
  const [errors, setErrors] = useState<FieldErrors>({})
  const [busy, setBusy] = useState(false)
  const name = user.displayName || user.username

  function set<K extends keyof SetPasswordFields>(key: K, value: SetPasswordFields[K]) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => {
      if (!current[key]) return current
      const next = { ...current }
      delete next[key]
      return next
    })
  }

  function error(key: keyof SetPasswordFields): string | undefined {
    const code = errors[key]
    return code ? t(code) : undefined
  }

  async function submit(event: FormEvent) {
    event.preventDefault()
    const next = validateSetPassword(fields, user.username)
    setErrors(next)
    if (hasFieldErrors(next)) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      await setUserPassword(token, user.id, fields.password)
      toast.success(t('usersPasswordSaved'))
      onSaved()
    } catch (caught) {
      if (caught instanceof ApiError) {
        const field = apiField[caught.code]
        if (field) {
          const key = usersErrorKey(caught)
          setErrors((current) => ({ ...current, [field]: key }))
          toast.error(t(key))
          setBusy(false)
          return
        }
      }
      toast.error(t(usersErrorKey(caught)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('usersPasswordTitle')}
      description={t('usersPasswordIntro', { name, username: user.username })}
      size="md"
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
            loadingLabel={t('usersPasswordSaving')}
            className="sm:w-auto sm:min-w-40"
          >
            {t('usersPasswordSave')}
          </LoadingButton>
        </>
      }
    >
      <form id={formId} className="space-y-4" onSubmit={(event) => void submit(event)}>
        <PasswordField
          id="set-user-password"
          label={t('fieldNewPassword')}
          autoComplete="new-password"
          value={fields.password}
          error={error('password')}
          onChange={(event) => set('password', event.target.value)}
        />
        <PasswordField
          id="set-user-confirm-password"
          label={t('fieldConfirmNewPassword')}
          autoComplete="new-password"
          value={fields.confirmPassword}
          error={error('confirmPassword')}
          onChange={(event) => set('confirmPassword', event.target.value)}
        />
      </form>
    </Modal>
  )
}
