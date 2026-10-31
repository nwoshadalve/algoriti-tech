/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery } from '@tanstack/react-query'
import { Fragment, useMemo, useState } from 'react'
import { listAuditLog } from '@/core/api/audit'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { Card } from '@/core/ui/Card'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { TextField } from '@/core/ui/TextField'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { auditQueryKeys } from '@/features/audit/auditQueryKeys'

function outcomeLabel(
  t: (key: MessageKey, params?: Record<string, string | number>) => string,
  outcome: string,
) {
  if (outcome === 'failed') return t('auditOutcomeFailed')
  if (outcome === 'refused') return t('auditOutcomeRefused')
  return t('auditOutcomeSuccess')
}

/** Admin audit trail — paginated, filterable ([audit-log.md]). */
export function AuditLogPage() {
  const { t, locale } = useLocale()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const isAdmin = account?.role === 'admin'

  const [actionPrefix, setActionPrefix] = useState('queue.')
  const [outcome, setOutcome] = useState('')
  const [applied, setApplied] = useState({ actionPrefix: 'queue.', outcome: '' })
  const [expanded, setExpanded] = useState<number | null>(null)

  const filters = useMemo(
    () => ({
      actionPrefix: applied.actionPrefix.trim() || undefined,
      outcome: applied.outcome.trim() || undefined,
    }),
    [applied.actionPrefix, applied.outcome],
  )

  const auditQuery = useInfiniteQuery({
    queryKey: auditQueryKeys.list(filters),
    queryFn: async ({ pageParam }) => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listAuditLog(token, { ...filters, offset: pageParam })
    },
    initialPageParam: 0,
    getNextPageParam: (lastPage) => lastPage.nextOffset ?? undefined,
    enabled: isAdmin,
    retry: false,
  })

  const entries = auditQuery.data?.pages.flatMap((page) => page.entries) ?? []
  const total = auditQuery.data?.pages[0]?.total ?? 0
  const loading = auditQuery.isPending && auditQuery.data === undefined
  const failed = auditQuery.isError && auditQuery.data === undefined

  if (!account) return null

  if (!isAdmin) {
    return (
      <div>
        <PageHeader title={t('navAudit')} description={t('auditIntro')} />
        <NoticeBanner tone="error">{t('queueErrorForbidden')}</NoticeBanner>
      </div>
    )
  }

  const filteredEmpty =
    !loading && entries.length === 0 && (applied.actionPrefix.trim() || applied.outcome.trim())
  const empty = !loading && entries.length === 0 && !applied.actionPrefix.trim() && !applied.outcome.trim()

  function applyFilters() {
    setApplied({ actionPrefix, outcome })
  }

  return (
    <div>
      <PageHeader title={t('navAudit')} description={t('auditIntro')} />

      <Card className="mb-6 grid gap-4 md:grid-cols-3">
        <TextField
          id="audit-filter-action"
          label={t('auditFilterAction')}
          value={actionPrefix}
          onChange={(e) => setActionPrefix(e.target.value)}
        />
        <TextField
          id="audit-filter-outcome"
          label={t('auditFilterOutcome')}
          value={outcome}
          placeholder="success"
          onChange={(e) => setOutcome(e.target.value)}
        />
        <div className="flex items-end">
          <button type="button" className={secondaryButton} onClick={applyFilters}>
            {t('auditFilterApply')}
          </button>
        </div>
      </Card>

      {loading ? <PagePreloader /> : null}
      {failed ? <NoticeBanner tone="error">{t('auditEmpty')}</NoticeBanner> : null}
      {empty ? <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('auditEmpty')}</p> : null}
      {filteredEmpty ? (
        <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('auditEmptyFiltered')}</p>
      ) : null}

      {entries.length > 0 ? (
        <div className="overflow-x-auto rounded-xl border border-brand-navy/10 dark:border-white/10">
          <table className="min-w-full text-left text-sm">
            <thead className="bg-brand-mist/80 text-brand-navy/70 dark:bg-white/5 dark:text-white/70">
              <tr>
                <th className="px-4 py-3 font-semibold">{t('auditColumnWhen')}</th>
                <th className="px-4 py-3 font-semibold">{t('auditColumnAction')}</th>
                <th className="px-4 py-3 font-semibold">{t('auditColumnActor')}</th>
                <th className="px-4 py-3 font-semibold">{t('auditColumnOutcome')}</th>
                <th className="px-4 py-3 font-semibold">{t('auditDetails')}</th>
              </tr>
            </thead>
            <tbody>
              {entries.map((entry) => (
                <Fragment key={entry.id}>
                  <tr className="border-t border-brand-navy/8 dark:border-white/10">
                    <td className="px-4 py-3 whitespace-nowrap tabular-nums">
                      {new Intl.DateTimeFormat(locale, {
                        dateStyle: 'medium',
                        timeStyle: 'short',
                      }).format(new Date(entry.occurredAt))}
                    </td>
                    <td className="px-4 py-3 font-mono text-xs">{entry.action}</td>
                    <td className="px-4 py-3">
                      {entry.actorDisplayName ?? '—'}
                      {entry.actorRole ? ` (${entry.actorRole})` : ''}
                    </td>
                    <td className="px-4 py-3">{outcomeLabel(t, entry.outcome)}</td>
                    <td className="px-4 py-3">
                      <button
                        type="button"
                        className="text-brand-coral-action font-semibold"
                        onClick={() =>
                          setExpanded((current) => (current === entry.id ? null : entry.id))
                        }
                      >
                        {t('auditDetails')}
                      </button>
                    </td>
                  </tr>
                  {expanded === entry.id ? (
                    <tr className="border-t border-brand-navy/8 dark:border-white/10">
                      <td colSpan={5} className="px-4 py-3">
                        <pre className="overflow-x-auto rounded-lg bg-brand-navy/5 p-3 text-xs dark:bg-white/5">
                          {JSON.stringify(entry.safeMetadata, null, 2)}
                        </pre>
                      </td>
                    </tr>
                  ) : null}
                </Fragment>
              ))}
            </tbody>
          </table>
        </div>
      ) : null}

      {auditQuery.hasNextPage ? (
        <button
          type="button"
          className={`${secondaryButton} mt-6`}
          disabled={auditQuery.isFetchingNextPage}
          onClick={() => void auditQuery.fetchNextPage()}
        >
          {t('auditLoadMore')} ({entries.length}/{total})
        </button>
      ) : null}
    </div>
  )
}
