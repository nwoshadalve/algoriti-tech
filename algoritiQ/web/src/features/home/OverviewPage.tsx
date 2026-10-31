/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Link } from 'react-router-dom'
import { liveStateToHealth, useLiveChannel } from '@/core/api/LiveChannelProvider'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import type { MessageKey } from '@/core/i18n/messages/types'
import { Card } from '@/core/ui/Card'
import { ActivityIcon, ArrowRightIcon, SettingsIcon, UsersIcon } from '@/core/ui/icons'
import { PageHeader } from '@/core/ui/PageHeader'
import { useAuth } from '@/features/auth/authContext'

const shortcuts: {
  to: string
  titleKey: MessageKey
  descriptionKey: MessageKey
  icon: typeof UsersIcon
}[] = [
  { to: '/users', titleKey: 'navUsers', descriptionKey: 'shortcutUsersDesc', icon: UsersIcon },
  {
    to: '/monitoring',
    titleKey: 'navMonitoring',
    descriptionKey: 'shortcutMonitoringDesc',
    icon: ActivityIcon,
  },
  {
    to: '/settings',
    titleKey: 'navSettings',
    descriptionKey: 'shortcutSettingsDesc',
    icon: SettingsIcon,
  },
]

const statusStyle = {
  connected: 'bg-emerald-500',
  checking: 'animate-pulse bg-brand-navy/35 dark:bg-white/40',
  offline: 'bg-brand-coral',
} as const

/** First screen after sign-in: server status, the person's account and shortcuts. */
export function OverviewPage() {
  const { t } = useLocale()
  const { state } = useAuth()
  const { state: liveState } = useLiveChannel()
  const health = liveStateToHealth(liveState)
  const account = state.status === 'signedIn' ? state.account : null
  const name = account ? account.firstName || account.displayName || account.username : ''

  const serverMessage: MessageKey =
    health === 'connected'
      ? 'overviewServerOk'
      : health === 'offline'
        ? 'overviewServerOffline'
        : 'overviewServerChecking'

  return (
    <div className="min-w-0">
      <PageHeader
        title={t('homeGreeting', { name })}
        description={t('overviewIntro')}
      />

      <div className="grid min-w-0 gap-4 sm:gap-6 md:grid-cols-2">
        <Card as="section" labelledBy="overview-server">
          <h2 id="overview-server" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
            {t('overviewServerTitle')}
          </h2>
          <p className="mt-3 flex items-start gap-3 text-base font-medium">
            <span
              className={`mt-1.5 h-3 w-3 shrink-0 rounded-full ${statusStyle[health]}`}
              aria-hidden="true"
            />
            <span className="min-w-0 flex-1" role="status">{t(serverMessage)}</span>
          </p>
        </Card>

        {account ? (
          <Card as="section" labelledBy="overview-account">
            <h2 id="overview-account" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
              {t('overviewAccountTitle')}
            </h2>
            <dl className="mt-3 grid min-w-0 grid-cols-[minmax(0,auto)_minmax(0,1fr)] gap-x-4 gap-y-1.5 text-sm">
              <dt className="text-brand-navy/60 dark:text-white/60">{t('fieldRole')}</dt>
              <dd className="min-w-0 font-medium">{t(roleLabelKey[account.role])}</dd>
              <dt className="text-brand-navy/60 dark:text-white/60">{t('fieldUsername')}</dt>
              <dd className="min-w-0 font-medium">{account.username}</dd>
              <dt className="text-brand-navy/60 dark:text-white/60">{t('fieldEmail')}</dt>
              <dd className="min-w-0 font-medium">{account.email}</dd>
            </dl>
          </Card>
        ) : null}
      </div>

      <h2 className="mt-10 mb-4 text-lg font-semibold">{t('overviewShortcutsTitle')}</h2>
      <ul className="grid gap-4 sm:grid-cols-2 sm:gap-6 xl:grid-cols-3">
        {shortcuts.map(({ to, titleKey, descriptionKey, icon: Icon }) => (
          <li key={to}>
            <Link
              to={to}
              className="group flex h-full items-start gap-4 rounded-2xl border border-brand-navy/10 bg-white p-5 shadow-sm transition-colors hover:border-brand-navy/30 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:border-white/10 dark:bg-brand-navy-raised dark:hover:border-white/30"
            >
              <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-brand-navy/5 text-brand-navy dark:bg-white/10 dark:text-white">
                <Icon />
              </span>
              <span className="min-w-0 flex-1">
                <span className="block font-semibold">{t(titleKey)}</span>
                <span className="mt-1 block text-sm text-brand-navy/70 dark:text-white/70">
                  {t(descriptionKey)}
                </span>
              </span>
              <ArrowRightIcon className="mt-1 shrink-0 text-brand-navy/40 transition-transform group-hover:translate-x-0.5 dark:text-white/40" />
            </Link>
          </li>
        ))}
      </ul>

      <Card as="section" labelledBy="overview-queue" className="mt-10 border-dashed">
        <h2 id="overview-queue" className="font-semibold">
          {t('overviewQueueTitle')}
        </h2>
        <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('overviewQueueSoon')}</p>
      </Card>
    </div>
  )
}
