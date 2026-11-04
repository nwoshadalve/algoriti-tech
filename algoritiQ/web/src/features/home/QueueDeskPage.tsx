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

/** Queue desk for admin and receptionist (shared mock screen 10 layout). */
export function QueueDeskPage() {
  const { t } = useLocale()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null

  if (!account) return null

  if (account.role === 'admin') {
    return <QueueBoardPage role="admin" />
  }

  if (account.role === 'receptionist') {
    return <QueueBoardPage role="receptionist" />
  }

  return (
    <div>
      <PageHeader title={t('navQueueDesk')} description={t('boardIntro')} />
      <NoticeBanner tone="error">{t('boardErrorForbidden')}</NoticeBanner>
    </div>
  )
}
