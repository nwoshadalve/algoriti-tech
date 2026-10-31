/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { liveStateToHealth, useLiveChannel } from '@/core/api/LiveChannelProvider'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import type { MessageKey } from '@/core/i18n/messages/types'
import { Card } from '@/core/ui/Card'
import { PageHeader } from '@/core/ui/PageHeader'
import type { Account } from '@/core/api/types'
import { useAuth } from '@/features/auth/authContext'
import { AdminQueueBoardPage } from '@/features/board/AdminQueueBoardPage'
import { useWorkScope } from '@/features/work/workScopeContext'

const statusStyle = {
  connected: 'bg-emerald-500',
  checking: 'animate-pulse bg-brand-navy/35 dark:bg-white/40',
  offline: 'bg-brand-coral',
} as const

/** Home board: admin queue operations or receptionist counter overview. */
export function BoardPage() {
  const { t } = useLocale()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null

  if (account?.role === 'admin') {
    return <AdminQueueBoardPage />
  }

  return <ReceptionistBoardPlaceholder account={account} t={t} />
}

function ReceptionistBoardPlaceholder({
  account,
  t,
}: {
  account: Account | null
  t: (key: MessageKey, params?: Record<string, string | number>) => string
}) {
  const { state: liveState } = useLiveChannel()
  const { state: workScope } = useWorkScope()
  const health = liveStateToHealth(liveState)
  const name = account ? account.firstName || account.displayName || account.username : ''
  const description =
    workScope.status === 'ready'
      ? t('workScopeActive', { name: workScope.selected.name })
      : t('boardIntro')

  const serverMessage: MessageKey =
    health === 'connected'
      ? 'overviewServerOk'
      : health === 'offline'
        ? 'overviewServerOffline'
        : 'overviewServerChecking'

  return (
    <div className="min-w-0">
      <PageHeader title={t('homeGreeting', { name })} description={description} />

      <div className="grid min-w-0 gap-4 sm:gap-6 md:grid-cols-2">
        <Card as="section" labelledBy="board-server">
          <h2 id="board-server" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
            {t('overviewServerTitle')}
          </h2>
          <p className="mt-3 flex items-start gap-3 text-base font-medium">
            <span
              className={`mt-1.5 h-3 w-3 shrink-0 rounded-full ${statusStyle[health]}`}
              aria-hidden="true"
            />
            <span className="min-w-0 flex-1" role="status">
              {t(serverMessage)}
            </span>
          </p>
        </Card>

        {account ? (
          <Card as="section" labelledBy="board-account">
            <h2 id="board-account" className="text-sm font-semibold text-brand-navy/70 dark:text-white/70">
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

      <Card as="section" labelledBy="board-queue" className="mt-10 border-dashed">
        <h2 id="board-queue" className="font-semibold">
          {t('overviewQueueTitle')}
        </h2>
        <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('overviewQueueSoon')}</p>
      </Card>
    </div>
  )
}
