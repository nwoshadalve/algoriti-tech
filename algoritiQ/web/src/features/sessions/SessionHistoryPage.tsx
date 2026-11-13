/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery } from '@tanstack/react-query'
import { useMemo, useState } from 'react'
import { listSessionHistory } from '@/core/api/sessionHistory'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SelectField } from '@/core/ui/SelectField'
import { readSession } from '@/features/auth/session'
import { SessionCard } from '@/features/sessions/SessionCard'
import { sessionHistoryQueryKeys } from '@/features/sessions/sessionHistoryQueryKeys'

const PAGE_SIZE = 20
const DAY_MS = 24 * 60 * 60 * 1000

type Range = '7' | '30' | 'all'

/** Earlier queue sessions: when each ran and what happened in it. */
export function SessionHistoryPage() {
  const { t } = useLocale()
  const [range, setRange] = useState<Range>('7')
  const [chamberId, setChamberId] = useState('')
  const [now] = useState(() => Date.now())
  // The period start is fixed per choice so paging stays on one list.
  const from = useMemo(
    () => (range === 'all' ? '' : new Date(now - Number(range) * DAY_MS).toISOString()),
    [range, now],
  )

  const query = useInfiniteQuery({
    queryKey: sessionHistoryQueryKeys.list(chamberId, from),
    queryFn: async ({ pageParam }) => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listSessionHistory(token, {
        chamberId: chamberId || undefined,
        from: from || undefined,
        limit: PAGE_SIZE,
        offset: pageParam,
      })
    },
    initialPageParam: 0,
    getNextPageParam: (last, pages) => {
      const loaded = pages.reduce((sum, page) => sum + page.items.length, 0)
      return loaded < last.total ? loaded : undefined
    },
    retry: false,
  })

  const sessions = query.data?.pages.flatMap((page) => page.items) ?? []
  const chambers = query.data?.pages[0]?.chambers ?? []
  const loading = query.isPending && query.data === undefined
  const failed = query.isError && query.data === undefined

  return (
    <div>
      <PageHeader title={t('navSessionHistory')} description={t('historyIntro')} />

      <div className="mb-6 flex flex-wrap items-end gap-3">
        <SelectField
          id="history-range"
          label={t('historyRange')}
          value={range}
          onChange={(event) => setRange(event.target.value as Range)}
          options={[
            { value: '7', label: t('historyRange7') },
            { value: '30', label: t('historyRange30') },
            { value: 'all', label: t('historyRangeAll') },
          ]}
          className="min-w-44"
        />
        {chambers.length > 1 ? (
          <SelectField
            id="history-chamber"
            label={t('historyChamber')}
            value={chamberId}
            onChange={(event) => setChamberId(event.target.value)}
            options={[
              { value: '', label: t('historyAllChambers') },
              ...chambers.map((c) => ({ value: c.id, label: c.name })),
            ]}
            className="min-w-44"
          />
        ) : null}
      </div>

      {loading ? <PagePreloader /> : null}
      {failed ? (
        <NoticeBanner tone="error">
          {t('historyLoadFailed')}
          <button type="button" className={`${secondaryButton} mt-2`} onClick={() => void query.refetch()}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      ) : null}
      {!loading && !failed && sessions.length === 0 ? (
        <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('historyEmpty')}</p>
      ) : null}

      {sessions.length > 0 ? (
        <ul className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {sessions.map((session) => (
            <li key={session.id}>
              <SessionCard session={session} showChamber={chambers.length > 1} />
            </li>
          ))}
        </ul>
      ) : null}

      {query.hasNextPage ? (
        <button
          type="button"
          className={`${secondaryButton} mt-6`}
          disabled={query.isFetchingNextPage}
          onClick={() => void query.fetchNextPage()}
        >
          {t('historyShowMore')}
        </button>
      ) : null}
    </div>
  )
}
