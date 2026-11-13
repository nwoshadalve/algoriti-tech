/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState, type FormEvent, type ReactNode } from 'react'
import { BootstrapScreen } from '@/app/BootstrapScreen'
import { probeTablet } from '@/app/tabletProbe'
import { useLocale } from '@/core/i18n/LocaleProvider'
import {
  clearServerAddress,
  parseServerAddress,
  readServerAddress,
  saveServerAddress,
} from '@/core/serverAddress'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { TextField } from '@/core/ui/TextField'

type Phase = 'checking' | 'ready' | 'unreachable'

/**
 * Shows the app only once the clinic tablet answers. When it does not (the
 * name `algoritiq.local` does not resolve on this phone), the person types the
 * tablet's IP address; it is remembered in this browser.
 */
export function ConnectionGate({ children }: { children: ReactNode }) {
  const [phase, setPhase] = useState<Phase>('checking')

  const check = useCallback(() => {
    setPhase('checking')
    let cancelled = false
    void probeTablet(null).then((ok) => {
      if (!cancelled) setPhase(ok ? 'ready' : 'unreachable')
    })
    return () => {
      cancelled = true
    }
  }, [])

  useEffect(() => check(), [check])

  if (phase === 'ready') return <>{children}</>
  if (phase === 'checking') return <BootstrapScreen />
  return <ConnectScreen onRetry={check} />
}

function ConnectScreen({ onRetry }: { onRetry: () => void }) {
  const { t } = useLocale()
  const saved = readServerAddress()
  const [value, setValue] = useState(() => (saved ? new URL(saved).hostname : ''))
  const [error, setError] = useState<string | null>(null)
  const [certHelpOrigin, setCertHelpOrigin] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  async function submit(event: FormEvent) {
    event.preventDefault()
    const origin = parseServerAddress(value)
    if (!origin) {
      setError(t('connectInvalid'))
      setCertHelpOrigin(null)
      return
    }
    setBusy(true)
    setError(null)
    const ok = await probeTablet(origin)
    setBusy(false)
    if (!ok) {
      setError(t('connectFailed'))
      setCertHelpOrigin(origin)
      return
    }
    saveServerAddress(origin)
    // Reload so every part of the app starts with the new address.
    window.location.reload()
  }

  return (
    <main className="flex min-h-dvh items-center justify-center bg-brand-mist px-4 py-8 text-brand-navy dark:bg-brand-navy dark:text-white">
      <section className="w-full max-w-md rounded-2xl border border-brand-navy/10 bg-white p-6 shadow-lg shadow-brand-navy/[0.06] dark:border-brand-navy-line dark:bg-brand-navy-raised dark:shadow-none">
        <h1 className="text-2xl font-semibold tracking-tight">{t('connectTitle')}</h1>
        <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
          {t('connectBody')}
        </p>
        <form className="mt-5 space-y-4" onSubmit={(event) => void submit(event)} noValidate>
          <TextField
            id="tablet-address"
            label={t('connectField')}
            hint={t('connectHint')}
            value={value}
            onChange={(event) => {
              setValue(event.target.value)
              setError(null)
              setCertHelpOrigin(null)
            }}
            error={error ?? undefined}
            inputMode="decimal"
            autoComplete="off"
            autoCapitalize="none"
            autoCorrect="off"
            spellCheck={false}
            disabled={busy}
          />
          {certHelpOrigin ? (
            <p className="rounded-lg bg-brand-mist px-3 py-2 text-xs leading-relaxed text-brand-navy/80 dark:bg-brand-navy dark:text-white/80">
              {t('connectCertHelp')}{' '}
              <a
                href={`${certHelpOrigin}/ca.crt`}
                target="_blank"
                rel="noopener noreferrer"
                className="font-semibold underline"
              >
                {t('connectOpenTablet')}
              </a>
            </p>
          ) : null}
          <LoadingButton type="submit" isLoading={busy} loadingLabel={t('connectChecking')}>
            {t('connectSubmit')}
          </LoadingButton>
        </form>
        <div className="mt-3 flex flex-col gap-2">
          <button
            type="button"
            onClick={onRetry}
            disabled={busy}
            className="min-h-11 w-full rounded-lg border border-brand-navy/15 px-4 text-sm font-semibold focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none disabled:opacity-60 dark:border-brand-navy-line"
          >
            {t('connectRetry')}
          </button>
          {saved ? (
            <button
              type="button"
              onClick={() => {
                clearServerAddress()
                window.location.reload()
              }}
              disabled={busy}
              className="min-h-11 w-full rounded-lg px-4 text-sm font-medium text-brand-navy/75 underline focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:text-white/75"
            >
              {t('connectUseDefault')}
            </button>
          ) : null}
        </div>
      </section>
    </main>
  )
}
