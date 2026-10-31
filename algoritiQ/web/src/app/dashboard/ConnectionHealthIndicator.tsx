/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

/** Status chip for the live connection to the clinic tablet. */
export type ConnectionHealthState = 'connected' | 'checking' | 'offline'

type ConnectionHealthIndicatorProps = {
  state?: ConnectionHealthState
  /** Dot only (the label stays for screen readers): for the narrow top bar. */
  compact?: boolean
}

export function ConnectionHealthIndicator({
  state = 'checking',
  compact = false,
}: ConnectionHealthIndicatorProps) {
  const { t } = useLocale()

  const label =
    state === 'connected'
      ? t('connectionConnected')
      : state === 'offline'
        ? t('connectionOffline')
        : t('connectionChecking')

  const dotClass =
    state === 'connected'
      ? 'bg-emerald-500'
      : state === 'offline'
        ? 'bg-brand-coral'
        : 'bg-brand-navy/35 animate-pulse dark:bg-white/40'

  return (
    <div
      className={[
        'flex min-w-0 items-center gap-2 rounded-full text-xs font-medium text-brand-navy/80 dark:text-white/80',
        compact
          ? 'h-9 w-9 justify-center border border-brand-navy/12 dark:border-white/12'
          : 'px-1 py-1',
      ].join(' ')}
      role="status"
      aria-live="polite"
      title={label}
    >
      <span className={`h-2.5 w-2.5 shrink-0 rounded-full ${dotClass}`} aria-hidden="true" />
      <span className={compact ? 'sr-only' : 'truncate'}>{label}</span>
    </div>
  )
}
