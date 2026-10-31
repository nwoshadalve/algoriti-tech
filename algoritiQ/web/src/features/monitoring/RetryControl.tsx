/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { HealthService } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { BrandLoader } from '@/core/ui/BrandLoader'
import { RefreshIcon } from '@/core/ui/icons'

type RetryControlProps = {
  service: HealthService
  /** What the retry is for, e.g. "POS printer" (for screen readers). */
  name: string
  onRetry: () => void
}

/**
 * The retry affordance of a part that is down: a refresh button, and while it
 * is trying the three-dot loader with "Attempt 2 of 3".
 */
export function RetryControl({ service, name, onRetry }: RetryControlProps) {
  const { t } = useLocale()

  if (service.status === 'retrying') {
    const retry = service.retry
    const progress = !retry
      ? ''
      : retry.max > 0
        ? t('monitorRetryProgress', { attempt: retry.attempt, max: retry.max })
        : t('monitorRetryAttempt', { attempt: retry.attempt })
    return (
      <div className="flex min-h-11 items-center gap-2 text-xs font-medium" role="status">
        <BrandLoader dotSize={6} semanticLabel={t('monitorStatusRetrying')} />
        <span>{progress}</span>
      </div>
    )
  }

  if (!service.retryable || (service.status !== 'failed' && service.status !== 'unavailable')) {
    return null
  }

  return (
    <button
      type="button"
      onClick={onRetry}
      aria-label={t('monitorRetryService', { name })}
      className="inline-flex min-h-10 items-center gap-1.5 rounded-lg border border-brand-navy/15 px-2.5 text-xs font-medium text-brand-navy hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none sm:min-h-11 sm:gap-2 sm:rounded-xl sm:px-3 sm:text-sm dark:border-white/20 dark:text-white dark:hover:bg-white/10"
    >
      <RefreshIcon width={16} height={16} />
      {t('monitorRetry')}
    </button>
  )
}
