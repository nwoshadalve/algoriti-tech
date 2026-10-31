/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { HealthStatus } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { AlertCircleIcon, CheckCircleIcon } from '@/core/ui/icons'

const labelKeys: Record<HealthStatus, MessageKey> = {
  ok: 'monitorStatusOk',
  warning: 'monitorStatusWarning',
  failed: 'monitorStatusFailed',
  unavailable: 'monitorStatusUnavailable',
  retrying: 'monitorStatusRetrying',
}

const tone: Record<HealthStatus, string> = {
  ok: 'bg-emerald-50 text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-200',
  warning: 'bg-amber-50 text-amber-950 dark:bg-amber-950/50 dark:text-amber-100',
  failed: 'bg-red-50 text-red-900 dark:bg-red-950/50 dark:text-red-100',
  unavailable: 'bg-brand-navy/5 text-brand-navy/80 dark:bg-white/10 dark:text-white/80',
  retrying: 'bg-brand-navy/5 text-brand-navy dark:bg-white/10 dark:text-white',
}

/** The state as a word and an icon, never colour alone. */
export function StatusBadge({ status }: { status: HealthStatus }) {
  const { t } = useLocale()
  return (
    <span
      className={`inline-flex shrink-0 items-center gap-1 rounded-full px-2 py-0.5 text-[11px] font-semibold whitespace-nowrap sm:gap-1.5 sm:px-2.5 sm:py-1 sm:text-xs ${tone[status]}`}
    >
      {status === 'ok' ? (
        <CheckCircleIcon width={14} height={14} />
      ) : status === 'retrying' ? null : (
        <AlertCircleIcon width={14} height={14} />
      )}
      {t(labelKeys[status])}
    </span>
  )
}
