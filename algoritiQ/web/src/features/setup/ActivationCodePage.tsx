/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { SetupAside } from '@/features/setup/SetupAside'
import { SetupProgress } from '@/features/setup/SetupProgress'
import { SetupCard } from '@/core/ui/SetupCard'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { TextField } from '@/core/ui/TextField'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { getSetupStatus, verifyClaimCode } from '@/core/api/setup'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { validateActivationCode } from '@/features/setup/adminRegistrationValidation'
import { saveVerifiedClaimCode, takeActivationFlash } from '@/features/setup/claimCodeSession'
import { setupErrorKey, setupErrorParams } from '@/features/setup/setupErrorMessages'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'

type Phase = { kind: 'loading' } | { kind: 'activate' }

export function ActivationCodePage() {
  const { t } = useLocale()
  const navigate = useNavigate()
  const [phase, setPhase] = useState<Phase>({ kind: 'loading' })
  const [code, setCode] = useState('')
  const [errorKey, setErrorKey] = useState<MessageKey | null>(null)
  const toast = useToast()
  const [submitting, setSubmitting] = useState(false)

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        await getSetupStatus()
        if (cancelled) return
        setPhase({ kind: 'activate' })
        const flash = takeActivationFlash()
        if (flash) toast.error(flash)
      } catch {
        if (!cancelled) {
          setPhase({ kind: 'activate' })
          toast.error(takeActivationFlash() ?? t('errorStatusCheck'))
        }
      }
    })()
    return () => {
      cancelled = true
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- mount only
  }, [])

  async function onSubmit(event: React.FormEvent) {
    event.preventDefault()
    const key = validateActivationCode(code)
    if (key) {
      setErrorKey(key)
      return
    }

    setSubmitting(true)
    setErrorKey(null)
    try {
      await verifyClaimCode(code)
      saveVerifiedClaimCode(code)
      navigate('/register')
    } catch (error) {
      const apiKey = setupErrorKey(error)
      if (apiKey === 'errorAdminAlreadyRegistered') {
        navigate('/login', { replace: true })
        return
      }
      toast.error(t(apiKey, setupErrorParams(error)))
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <SetupLayout aside={<SetupAside activeStep={2} />} mobileHeader={<SetupProgress activeStep={2} />}>
      {phase.kind === 'loading' ? (
        <SetupCard labelledBy="loading">
          <PagePreloader className="py-10" />
        </SetupCard>
      ) : null}

      {phase.kind === 'activate' ? (
        <SetupCard labelledBy="activation-heading">
          <h1 id="activation-heading" className="text-xl font-semibold tracking-tight sm:text-2xl">
            {t('activationTitle')}
          </h1>
          <p className="mt-2 text-sm text-brand-navy/75 dark:text-white/75">{t('activationIntro')}</p>

          <form className="mt-6 space-y-4" onSubmit={onSubmit} noValidate>
            <TextField
              id="activationCode"
              name="activationCode"
              label={t('fieldActivationCode')}
              hint={t('fieldActivationCodeHint')}
              autoComplete="one-time-code"
              inputMode="text"
              spellCheck={false}
              value={code}
              error={errorKey ? t(errorKey) : undefined}
              onChange={(e) => {
                setCode(e.target.value)
                setErrorKey(null)
              }}
            />
            <LoadingButton type="submit" isLoading={submitting} className="w-full">
              {t('activationContinue')}
            </LoadingButton>
          </form>
        </SetupCard>
      ) : null}
    </SetupLayout>
  )
}
