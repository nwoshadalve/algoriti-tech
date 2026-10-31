/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { HealthService, ServiceId } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { RetryControl } from '@/features/monitoring/RetryControl'
import { ServiceCard } from '@/features/monitoring/ServiceCard'
import { StatusBadge } from '@/features/monitoring/StatusBadge'
import { formatUptime } from '@/features/monitoring/format'
import { reasonKey } from '@/features/monitoring/monitoringReasons'
import {
  priorityServiceOrder,
  serviceMeta,
  supportServiceOrder,
} from '@/features/monitoring/serviceMeta'

type ServicesPanelProps = {
  services: HealthService[]
  onRetry: (id: ServiceId) => void
  onTestPrint?: () => void
  testPrintBusy?: boolean
}

function byId(services: HealthService[], id: ServiceId): HealthService | undefined {
  return services.find((s) => s.id === id)
}

/** Printer and TV first, then server connectivity in a compact list. */
export function ServicesPanel({ services, onRetry, onTestPrint, testPrintBusy }: ServicesPanelProps) {
  const { t } = useLocale()

  return (
    <div className="space-y-6">
      <section aria-labelledby="monitor-clinic-devices" className="space-y-3">
        <h2 id="monitor-clinic-devices" className="text-sm font-semibold text-brand-navy dark:text-white sm:text-base">
          {t('monitorClinicDevices')}
        </h2>
        <ul className="grid grid-cols-1 gap-3 min-[520px]:grid-cols-2">
          {priorityServiceOrder.map((id) => {
            const service = byId(services, id)
            if (!service) return null
            const { labelKey, icon } = serviceMeta[id]
            return (
              <ServiceCard
                key={id}
                serviceId={id}
                name={t(labelKey)}
                icon={icon}
                service={service}
                priority
                showRetry={id !== 'tv'}
                onRetry={() => onRetry(id)}
                onTestPrint={id === 'printer' ? onTestPrint : undefined}
                testPrintBusy={id === 'printer' ? testPrintBusy : undefined}
              />
            )
          })}
        </ul>
      </section>

      <section aria-labelledby="monitor-system-services" className="space-y-3">
        <h2 id="monitor-system-services" className="text-sm font-semibold text-brand-navy dark:text-white sm:text-base">
          {t('monitorSystemServices')}
        </h2>
        <ul className="divide-y divide-brand-navy/10 overflow-hidden rounded-xl border border-brand-navy/10 bg-white dark:divide-white/10 dark:border-brand-navy-line dark:bg-brand-navy-raised">
          {supportServiceOrder.map((id) => {
            const service = byId(services, id)
            if (!service) return null
            const { labelKey, icon: Icon } = serviceMeta[id]
            const name = t(labelKey)
            const details = [
              service.uptimeSeconds === undefined
                ? null
                : t('monitorUptimeValue', { value: formatUptime(t, service.uptimeSeconds) }),
              service.clients === undefined ? null : t('monitorClients', { count: service.clients }),
            ].filter((part): part is string => part !== null)

            return (
              <li
                key={id}
                className="flex flex-col gap-2 p-3 min-[480px]:flex-row min-[480px]:items-center min-[480px]:gap-4 min-[480px]:p-3.5"
              >
                <div className="flex min-w-0 flex-1 items-start gap-2.5">
                  <Icon className="mt-0.5 shrink-0 text-brand-navy dark:text-white" width={20} height={20} />
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap items-center gap-x-2 gap-y-1">
                      <h3 className="text-sm font-semibold leading-snug">{name}</h3>
                      <StatusBadge status={service.status} />
                    </div>
                    {service.reason ? (
                      <p className="mt-0.5 text-xs leading-snug text-brand-navy/75 dark:text-white/75">
                        {t(reasonKey(service.reason))}
                      </p>
                    ) : details.length > 0 ? (
                      <p className="mt-0.5 text-xs leading-snug text-brand-navy/70 tabular-nums dark:text-white/70">
                        {details.join(' · ')}
                      </p>
                    ) : service.status === 'ok' ? (
                      <p className="mt-0.5 text-xs leading-snug text-brand-navy/70 dark:text-white/70">
                        {t('monitorNoReason')}
                      </p>
                    ) : null}
                  </div>
                </div>
                <div className="shrink-0 pl-7 min-[480px]:pl-0">
                  <RetryControl service={service} name={name} onRetry={() => onRetry(id)} />
                </div>
              </li>
            )
          })}
        </ul>
      </section>
    </div>
  )
}
