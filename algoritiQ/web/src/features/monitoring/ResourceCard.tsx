/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, ReactNode, SVGProps } from 'react'
import type { HealthResource } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { StatusBadge } from '@/features/monitoring/StatusBadge'
import { reasonKey } from '@/features/monitoring/monitoringReasons'

type ResourceCardProps = {
  name: string
  icon: ComponentType<SVGProps<SVGSVGElement>>
  resource: HealthResource
  value: ReactNode
  caption?: string
  action?: ReactNode
}

const barTone = {
  ok: 'bg-emerald-500',
  warning: 'bg-amber-500',
  failed: 'bg-brand-coral',
  unavailable: 'bg-brand-navy/30 dark:bg-white/30',
  retrying: 'bg-brand-navy/30 dark:bg-white/30',
} as const

/** CPU, memory or storage — one row per card, responsive width. */
export function ResourceCard({ name, icon: Icon, resource, value, caption, action }: ResourceCardProps) {
  const { t } = useLocale()
  const percent =
    resource.percent === undefined ? null : Math.min(100, Math.max(0, resource.percent))

  return (
    <li className="flex min-w-0 flex-col gap-2.5 rounded-xl border border-brand-navy/10 bg-white p-3.5 shadow-sm dark:border-brand-navy-line dark:bg-brand-navy-raised dark:shadow-none sm:p-4">
      <div className="flex min-w-0 items-start justify-between gap-3">
        <div className="flex min-w-0 items-center gap-2.5">
          <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brand-mist text-brand-navy dark:bg-white/10 dark:text-white">
            <Icon width={18} height={18} />
          </span>
          <div className="min-w-0">
            <h3 className="truncate text-sm font-semibold text-brand-navy dark:text-white">{name}</h3>
            {caption ? (
              <p className="mt-0.5 text-[11px] leading-snug text-brand-navy/70 tabular-nums dark:text-white/70">
                {caption}
              </p>
            ) : null}
          </div>
        </div>
        <div className="flex shrink-0 flex-col items-end gap-1.5">
          <p className="text-lg font-semibold leading-none tabular-nums text-brand-navy dark:text-white">
            {value}
          </p>
          <StatusBadge status={resource.status} />
        </div>
      </div>
      {percent !== null ? (
        <div
          role="progressbar"
          aria-label={name}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-valuenow={Math.round(percent)}
          className="h-2 overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/15"
        >
          <div
            className={`h-full rounded-full ${barTone[resource.status]}`}
            style={{ width: `${percent}%` }}
          />
        </div>
      ) : null}
      {resource.reason ? (
        <p className="text-xs leading-snug text-brand-navy/75 dark:text-white/75">{t(reasonKey(resource.reason))}</p>
      ) : null}
      {action ? <div>{action}</div> : null}
    </li>
  )
}
