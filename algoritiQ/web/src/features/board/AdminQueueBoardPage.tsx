/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { useAuth } from '@/features/auth/authContext'
import { QueueBoardPage } from '@/features/board/QueueBoardPage'

/** Admin queue desk (delegates to shared board layout). */
export function AdminQueueBoardPage() {
  const { t } = useLocale()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null

  if (!account) return null

  if (account.role !== 'admin') {
    return (
      <div>
        <PageHeader title={t('navQueueDesk')} description={t('boardIntro')} />
        <NoticeBanner tone="error">{t('boardErrorForbidden')}</NoticeBanner>
      </div>
    )
  }

  return <QueueBoardPage role="admin" />
}
