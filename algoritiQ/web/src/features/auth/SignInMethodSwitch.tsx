/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { SignInMode } from '@/features/auth/signInPreference'

type Props = {
  mode: SignInMode
  onChange: (mode: SignInMode) => void
  disabled?: boolean
}

export function SignInMethodSwitch({ mode, onChange, disabled }: Props) {
  const { t } = useLocale()

  const base =
    'inline-flex min-h-11 flex-1 items-center justify-center rounded-md px-3 text-sm font-semibold transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-coral disabled:cursor-not-allowed disabled:opacity-60'
  const active =
    'bg-white text-brand-navy shadow-sm dark:bg-brand-navy-line dark:text-white'
  const idle =
    'text-brand-navy/70 hover:text-brand-navy dark:text-white/70 dark:hover:text-white'

  return (
    <div
      role="radiogroup"
      aria-label={t('signInMethodLabel')}
      className="flex rounded-lg border border-brand-navy/15 bg-brand-navy/5 p-1 dark:border-white/15 dark:bg-white/5"
    >
      <button
        type="button"
        role="radio"
        aria-checked={mode === 'password'}
        disabled={disabled}
        className={`${base} ${mode === 'password' ? active : idle}`}
        onClick={() => onChange('password')}
      >
        {t('signInMethodPassword')}
      </button>
      <button
        type="button"
        role="radio"
        aria-checked={mode === 'pin'}
        disabled={disabled}
        className={`${base} ${mode === 'pin' ? active : idle}`}
        onClick={() => onChange('pin')}
      >
        {t('signInMethodPin')}
      </button>
    </div>
  )
}
