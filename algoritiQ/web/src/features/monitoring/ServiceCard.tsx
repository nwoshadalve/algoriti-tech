/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, SVGProps } from 'react'
import type { HealthService } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { RetryControl } from '@/features/monitoring/RetryControl'
import { StatusBadge } from '@/features/monitoring/StatusBadge'
import { formatUptime } from '@/features/monitoring/format'
import { reasonKey } from '@/features/monitoring/monitoringReasons'

type ServiceCardProps = {
  name: string
  icon: ComponentType<SVGProps<SVGSVGElement>>
  service: HealthService
  onRetry: () => void
  /** Larger cards for printer and TV. */
  priority?: boolean
  /** False hides retry (e.g. TV until a real reconnect exists). */
  showRetry?: boolean
}

const accent: Record<HealthService['status'], string> = {
  ok: 'border-l-emerald-500',
  warning: 'border-l-amber-500',
  failed: 'border-l-brand-coral',
  unavailable: 'border-l-brand-navy/25 dark:border-l-white/25',
  retrying: 'border-l-brand-coral/70',
}

/** One service as a scannable card (priority layout for printer and TV). */
export function ServiceCard({ name, icon: Icon, service, onRetry, priority, showRetry = true }: ServiceCardProps) {
  const { t } = useLocale()

  const details = [
    service.uptimeSeconds === undefined
      ? null
      : t('monitorUptimeValue', { value: formatUptime(t, service.uptimeSeconds) }),
    service.clients === undefined ? null : t('monitorClients', { count: service.clients }),
  ].filter((part): part is string => part !== null)

  const secondary =
    service.reason && details.length > 0
      ? details.join(' · ')
      : !service.reason && details.length > 0
        ? details.join(' · ')
        : !service.reason
          ? t('monitorNoReason')
          : null

  return (
    <li
      className={`flex min-w-0 flex-col gap-3 rounded-xl border border-brand-navy/10 border-l-4 bg-white p-4 shadow-sm dark:border-brand-navy-line dark:bg-brand-navy-raised dark:shadow-none ${accent[service.status]} ${priority ? 'sm:min-h-[9.5rem]' : ''}`}
    >
      <div className="flex min-w-0 items-start gap-3">
        <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-mist text-brand-navy dark:bg-white/10 dark:text-white">
          <Icon width={22} height={22} />
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
            <h3 className={`min-w-0 font-semibold leading-snug ${priority ? 'text-base' : 'text-sm'}`}>
              {name}
            </h3>
            <StatusBadge status={service.status} />
          </div>
          {service.reason ? (
            <p className="mt-1 text-sm leading-snug text-brand-navy/80 dark:text-white/80">
              {t(reasonKey(service.reason))}
            </p>
          ) : null}
          {secondary ? (
            <p className="mt-1 text-xs leading-snug text-brand-navy/65 tabular-nums dark:text-white/65">
              {secondary}
            </p>
          ) : null}
        </div>
      </div>
      <div className="mt-auto pt-1">
        {showRetry ? <RetryControl service={service} name={name} onRetry={onRetry} /> : null}
      </div>
    </li>
  )
}
