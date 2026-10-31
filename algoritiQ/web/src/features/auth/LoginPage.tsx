/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { Link, Navigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { PasswordField } from '@/core/ui/PasswordField'
import { PinInput } from '@/core/ui/PinInput'
import { SetupCard } from '@/core/ui/SetupCard'
import { TextField } from '@/core/ui/TextField'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { AuthAside } from '@/features/auth/AuthAside'
import { authError } from '@/features/auth/authErrors'
import { useAuth } from '@/features/auth/authContext'
import { clearPinBrowser, readPinBrowser } from '@/features/auth/pinDevice'
import { SignInMethodSwitch } from '@/features/auth/SignInMethodSwitch'
import {
  readSignInMode,
  saveSignInMode,
  type SignInMode,
} from '@/features/auth/signInPreference'
import { dashboardHomePath } from '@/app/dashboard/dashboardHome'

function initialMode(): SignInMode {
  if (readPinBrowser() == null) return 'password'
  return readSignInMode()
}

export function LoginPage() {
  const { state } = useAuth()
  const [pinBrowser, setPinBrowser] = useState(readPinBrowser)
  const [mode, setMode] = useState<SignInMode>(initialMode)

  if (state.status === 'signedIn') {
    return <Navigate to={dashboardHomePath(state.account.role)} replace />
  }

  const dropPin = () => {
    clearPinBrowser()
    setPinBrowser(null)
    saveSignInMode('password')
    setMode('password')
  }

  const chooseMode = (next: SignInMode) => {
    saveSignInMode(next)
    setMode(next)
  }

  return (
    <SetupLayout aside={<AuthAside />}>
      {state.status === 'loading' ? (
        <SetupCard labelledBy="loading">
          <PagePreloader className="py-10" />
        </SetupCard>
      ) : (
        <SetupCard labelledBy="login-heading">
          <SignInCard
            pinBrowser={pinBrowser}
            mode={mode}
            onChooseMode={chooseMode}
            onPinRemoved={dropPin}
          />
        </SetupCard>
      )}
    </SetupLayout>
  )
}

type PinBrowser = NonNullable<ReturnType<typeof readPinBrowser>>

type SignInCardProps = {
  pinBrowser: PinBrowser | null
  mode: SignInMode
  onChooseMode: (mode: SignInMode) => void
  onPinRemoved: () => void
}

function SignInCard({ pinBrowser, mode, onChooseMode, onPinRemoved }: SignInCardProps) {
  const { t, locale } = useLocale()
  const { signIn, signInWithPin } = useAuth()
  const toast = useToast()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [remember, setRemember] = useState(false)
  const [pin, setPin] = useState('')
  const [fieldError, setFieldError] = useState<string | null>(null)
  const [submitting, setSubmitting] = useState(false)

  const pinAvailable = pinBrowser !== null
  const showPin = pinAvailable && mode === 'pin'
  const pinName = pinBrowser?.displayName || pinBrowser?.username || ''

  async function submitPassword(event: React.FormEvent) {
    event.preventDefault()
    if (!username.trim() || !password) {
      setFieldError(t('errorLoginRequired'))
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      await signIn(username, password, remember)
    } catch (error) {
      const { key, params } = authError(error, locale)
      toast.error(t(key, params))
      setPassword('')
    } finally {
      setSubmitting(false)
    }
  }

  async function submitPin(value: string) {
    if (submitting) return
    if (value.length !== 6) {
      setFieldError(t('errorPinRequired'))
      return
    }
    setFieldError(null)
    setSubmitting(true)
    try {
      await signInWithPin(value)
    } catch (error) {
      const { key, params } = authError(error, locale)
      const message = t(key, params)
      toast.error(message)
      setPin('')
      setSubmitting(false)
      const code = error instanceof ApiError ? error.code : ''
      if (code === 'invalid_pin') {
        setFieldError(message)
      } else if (code === 'pin_locked' || code === 'pin_unavailable') {
        onPinRemoved()
      }
    }
  }

  return (
    <>
      <h1 id="login-heading" className="text-2xl font-semibold tracking-tight">
        {t('loginTitle')}
      </h1>
      <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
        {showPin ? t('pinLoginIntro') : t('loginIntro')}
      </p>
      {showPin ? (
        <p className="mt-1 text-sm font-medium text-brand-navy dark:text-white">
          {t('pinLoginTitle', { name: pinName })}
        </p>
      ) : null}

      {pinAvailable ? (
        <div className="mt-5">
          <SignInMethodSwitch
            mode={mode}
            onChange={onChooseMode}
            disabled={submitting}
          />
        </div>
      ) : null}

      {showPin ? (
        <form
          className="mt-6 space-y-4"
          onSubmit={(event) => {
            event.preventDefault()
            void submitPin(pin)
          }}
          noValidate
        >
          <PinInput
            id="pin"
            label={t('fieldPin')}
            value={pin}
            onChange={(value) => {
              setPin(value)
              setFieldError(null)
            }}
            onComplete={(value) => void submitPin(value)}
            error={fieldError ?? undefined}
            disabled={submitting}
            autoFocus
          />
          <LoadingButton
            type="submit"
            isLoading={submitting}
            loadingLabel={t('loginSubmitting')}
          >
            {t('loginSubmit')}
          </LoadingButton>
        </form>
      ) : (
        <form className="mt-6 space-y-4" onSubmit={submitPassword} noValidate>
          <TextField
            id="username"
            name="username"
            label={t('fieldLoginIdentifier')}
            autoComplete="username"
            autoCapitalize="none"
            spellCheck={false}
            value={username}
            onChange={(e) => {
              setUsername(e.target.value)
              setFieldError(null)
            }}
          />
          <PasswordField
            id="password"
            name="password"
            label={t('fieldPassword')}
            autoComplete="current-password"
            value={password}
            error={fieldError ?? undefined}
            onChange={(e) => {
              setPassword(e.target.value)
              setFieldError(null)
            }}
          />
          <label className="flex min-h-11 cursor-pointer items-start gap-3 text-sm">
            <input
              type="checkbox"
              name="remember"
              checked={remember}
              onChange={(event) => setRemember(event.target.checked)}
              className="mt-0.5 size-5 shrink-0 accent-brand-coral-action"
            />
            <span>
              <span className="block font-medium">{t('loginRemember')}</span>
              <span className="mt-0.5 block text-xs text-brand-navy/65 dark:text-white/65">
                {t('loginRememberHint')}
              </span>
            </span>
          </label>
          <LoadingButton
            type="submit"
            isLoading={submitting}
            loadingLabel={t('loginSubmitting')}
            className="mt-2"
          >
            {t('loginSubmit')}
          </LoadingButton>
        </form>
      )}

      {!showPin ? (
        <div className="mt-5 flex flex-wrap items-center justify-center gap-x-2 text-sm">
          <Link
            to="/forgot-password"
            className="inline-flex min-h-11 items-center px-3 font-medium text-brand-coral-action underline-offset-2 hover:underline"
          >
            {t('forgotPasswordLink')}
          </Link>
        </div>
      ) : null}
    </>
  )
}
