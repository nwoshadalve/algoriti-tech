/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { Link } from 'react-router-dom'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PasswordField } from '@/core/ui/PasswordField'
import { TextField } from '@/core/ui/TextField'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { validateNewPassword, type NewPasswordErrors } from '@/features/auth/reset/resetValidation'

const linkStyle =
  'inline-flex min-h-11 items-center px-3 font-medium text-brand-coral-action underline-offset-2 hover:underline'

function StepHeading({ id, title, intro }: { id: string; title: string; intro: string }) {
  return (
    <>
      <h2 id={id} className="text-xl font-semibold tracking-tight sm:text-2xl">
        {title}
      </h2>
      <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">{intro}</p>
    </>
  )
}

function BackButton({ onClick, disabled }: { onClick: () => void; disabled?: boolean }) {
  const { t } = useLocale()
  return (
    <p className="mt-3 text-center text-sm">
      <button type="button" onClick={onClick} disabled={disabled} className={linkStyle}>
        {t('backButton')}
      </button>
    </p>
  )
}

type UsernameStepProps = {
  initial: string
  onSubmit: (username: string) => void
}

/** Step 1. Asks nothing of the tablet: it never confirms an account exists. */
export function UsernameStep({ initial, onSubmit }: UsernameStepProps) {
  const { t } = useLocale()
  const [username, setUsername] = useState(initial)
  const [error, setError] = useState<MessageKey | null>(null)

  function submit(event: React.FormEvent) {
    event.preventDefault()
    if (!username.trim()) {
      setError('errorUsernameRequired')
      return
    }
    onSubmit(username)
  }

  return (
    <>
      <StepHeading id="reset-heading" title={t('forgotTitle')} intro={t('resetUsernameIntro')} />
      <form className="mt-6 space-y-4" onSubmit={submit} noValidate>
        <TextField
          id="username"
          name="username"
          label={t('fieldUsername')}
          autoComplete="username"
          autoCapitalize="none"
          spellCheck={false}
          value={username}
          error={error ? t(error) : undefined}
          onChange={(e) => {
            setUsername(e.target.value)
            setError(null)
          }}
        />
        <LoadingButton type="submit" className="mt-2">
          {t('continueButton')}
        </LoadingButton>
      </form>
      <p className="mt-3 text-center text-sm">
        <Link to="/login" className={linkStyle}>
          {t('backToSignIn')}
        </Link>
      </p>
    </>
  )
}

type KeyStepProps = {
  busy: boolean
  onSubmit: (activationKey: string) => void
  onBack: () => void
}

/** Step 2. The tablet checks the key (and the username) here. */
export function KeyStep({ busy, onSubmit, onBack }: KeyStepProps) {
  const { t } = useLocale()
  const [key, setKey] = useState('')
  const [error, setError] = useState<MessageKey | null>(null)

  function submit(event: React.FormEvent) {
    event.preventDefault()
    if (!key.trim()) {
      setError('errorActivationKeyRequired')
      return
    }
    onSubmit(key)
  }

  return (
    <>
      <StepHeading id="reset-heading" title={t('resetKeyTitle')} intro={t('resetKeyIntro')} />
      <form className="mt-6 space-y-4" onSubmit={submit} noValidate>
        <div className="space-y-1.5">
          <label htmlFor="activationKey" className="block text-sm font-medium">
            {t('fieldActivationKey')}
          </label>
          <textarea
            id="activationKey"
            name="activationKey"
            rows={3}
            autoComplete="off"
            autoCapitalize="none"
            spellCheck={false}
            aria-invalid={error ? true : undefined}
            aria-describedby={error ? 'activationKey-error' : 'activationKey-hint'}
            className={[
              'block min-h-24 w-full resize-y rounded-lg border bg-white px-3 py-2.5 font-mono text-sm shadow-sm outline-none',
              'focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:bg-brand-navy dark:text-white',
              error
                ? 'border-red-500 dark:border-red-400'
                : 'border-brand-navy/15 dark:border-brand-navy-line',
            ].join(' ')}
            value={key}
            disabled={busy}
            onChange={(e) => {
              setKey(e.target.value)
              setError(null)
            }}
          />
          {error ? (
            <p id="activationKey-error" className="text-xs text-red-600 dark:text-red-300" role="alert">
              {t(error)}
            </p>
          ) : (
            <p id="activationKey-hint" className="text-xs text-brand-navy/60 dark:text-white/60">
              {t('fieldActivationKeyHint')}
            </p>
          )}
        </div>
        <LoadingButton type="submit" isLoading={busy} loadingLabel={t('checkingKey')} className="mt-2">
          {t('continueButton')}
        </LoadingButton>
      </form>
      <BackButton onClick={onBack} disabled={busy} />
    </>
  )
}

type PasswordStepProps = {
  username: string
  busy: boolean
  onSubmit: (newPassword: string) => void
  onBack: () => void
}

/** Step 3. Only reachable with a ticket from the tablet. */
export function PasswordStep({ username, busy, onSubmit, onBack }: PasswordStepProps) {
  const { t } = useLocale()
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [errors, setErrors] = useState<NewPasswordErrors>({})

  function submit(event: React.FormEvent) {
    event.preventDefault()
    const found = validateNewPassword(username, password, confirm)
    setErrors(found)
    if (Object.keys(found).length === 0) onSubmit(password)
  }

  return (
    <>
      <StepHeading
        id="reset-heading"
        title={t('resetPasswordTitle')}
        intro={t('resetPasswordIntro', { username })}
      />
      <form className="mt-6 space-y-4" onSubmit={submit} noValidate>
        <PasswordField
          id="newPassword"
          name="newPassword"
          label={t('fieldNewPassword')}
          hint={t('fieldPasswordHint')}
          autoComplete="new-password"
          value={password}
          disabled={busy}
          error={errors.newPassword ? t(errors.newPassword) : undefined}
          onChange={(e) => {
            setPassword(e.target.value)
            setErrors((prev) => ({ ...prev, newPassword: undefined }))
          }}
        />
        <PasswordField
          id="confirmPassword"
          name="confirmPassword"
          label={t('fieldConfirmNewPassword')}
          autoComplete="new-password"
          value={confirm}
          disabled={busy}
          error={errors.confirmPassword ? t(errors.confirmPassword) : undefined}
          onChange={(e) => {
            setConfirm(e.target.value)
            setErrors((prev) => ({ ...prev, confirmPassword: undefined }))
          }}
        />
        <LoadingButton type="submit" isLoading={busy} loadingLabel={t('resetSubmitting')} className="mt-2">
          {t('resetSubmit')}
        </LoadingButton>
      </form>
      <BackButton onClick={onBack} disabled={busy} />
    </>
  )
}
