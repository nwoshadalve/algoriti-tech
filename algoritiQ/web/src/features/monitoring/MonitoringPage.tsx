/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLiveChannel } from '@/core/api/LiveChannelProvider'
import type { HealthService, Monitoring, ServiceId } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { ResourcesGrid } from '@/features/monitoring/ResourcesGrid'
import { ServicesPanel } from '@/features/monitoring/ServicesPanel'
import { formatUptime } from '@/features/monitoring/format'
import { useMonitoring } from '@/features/monitoring/useMonitoring'
import { websocketHealth } from '@/features/monitoring/websocketHealth'

function withBrowserWebsocket(
  data: Monitoring,
  live: ReturnType<typeof useLiveChannel>,
): HealthService[] {
  return data.services.map((service) =>
    service.id === 'websocket'
      ? websocketHealth(live.state, live.attempt, service.clients, service.uptimeSeconds)
      : service,
  )
}

/** Admin monitoring: clinic devices first, then server services and tablet resources. */
export function MonitoringPage() {
  const { t, locale } = useLocale()
  const live = useLiveChannel()
  const { data, failed, retry, reload } = useMonitoring()

  function onRetry(id: ServiceId) {
    if (id === 'websocket') live.retry()
    else void retry(id)
  }

  const services = data ? withBrowserWebsocket(data, live) : []
  const updated = data
    ? new Intl.DateTimeFormat(locale, { timeStyle: 'medium' }).format(new Date(data.generatedAt))
    : null

  return (
    <div className="mx-auto w-full min-w-0 max-w-5xl space-y-6 sm:space-y-8">
      <header className="space-y-1 border-b border-brand-navy/10 pb-4 dark:border-white/10">
        <h1 className="text-lg font-semibold tracking-tight text-brand-navy dark:text-white sm:text-xl lg:text-2xl">
          {t('navMonitoring')}
        </h1>
        {data && updated ? (
          <p className="flex flex-col gap-0.5 text-xs text-brand-navy/70 tabular-nums dark:text-white/70 sm:flex-row sm:flex-wrap sm:gap-x-3">
            <span>{t('monitorDeviceUptime', { value: formatUptime(t, data.deviceUptimeSeconds) })}</span>
            <span className="hidden sm:inline" aria-hidden>
              ·
            </span>
            <span>{t('monitorUpdated', { time: updated })}</span>
          </p>
        ) : null}
      </header>

      {failed ? (
        <div
          role="alert"
          className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-amber-300/80 bg-amber-50 px-3 py-2.5 text-sm text-amber-950 dark:border-amber-500/40 dark:bg-amber-950/40 dark:text-amber-100"
        >
          <span>{t('monitorLoadFailed')}</span>
          {data ? null : (
            <button
              type="button"
              onClick={reload}
              className="inline-flex min-h-11 items-center rounded-xl border border-amber-400/80 px-3 text-sm font-medium focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:border-amber-500/50"
            >
              {t('monitorRetry')}
            </button>
          )}
        </div>
      ) : null}

      {!data ? (
        failed ? null : (
          <PagePreloader className="py-16" />
        )
      ) : (
        <>
          <ServicesPanel services={services} onRetry={onRetry} />

          <section
            aria-labelledby="monitor-resources"
            className="space-y-3 border-t border-brand-navy/10 pt-6 dark:border-white/10 sm:pt-8"
          >
            <h2
              id="monitor-resources"
              className="text-sm font-semibold text-brand-navy dark:text-white sm:text-base"
            >
              {t('monitorResources')}
            </h2>
            <ResourcesGrid resources={data.resources} />
          </section>
        </>
      )}
    </div>
  )
}
