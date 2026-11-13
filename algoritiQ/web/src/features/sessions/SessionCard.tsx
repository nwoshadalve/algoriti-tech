/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { Link } from 'react-router-dom'
import type { SessionSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { CalendarIcon, ClockIcon, MapPinIcon, PersonIcon } from '@/core/ui/icons'
import { SessionStatusPill } from '@/features/sessions/SessionParts'
import { OutcomeSummary } from '@/features/sessions/SessionStats'
import {
  formatBdt,
  formatClock,
  formatDayShort,
  formatRelativeDay,
  formatRunTime,
  totalTokens,
} from '@/features/sessions/sessionFormat'

/** A past or running queue session at a glance; opens its detail page. */
export function SessionCard({ session, showChamber }: { session: SessionSummary; showChamber: boolean }) {
  const { t, locale } = useLocale()
  const [now] = useState(() => Date.now())
  const open = !session.closedAt
  const nf = new Intl.NumberFormat(locale)
  const start = formatClock(locale, session.openedAt)
  const range = session.closedAt
    ? t('historyTimeRange', { start, end: formatClock(locale, session.closedAt) })
    : t('historyTimeOpen', { start })
  const reason = session.closeReason?.trim()
  const relativeDay = formatRelativeDay(locale, session.openedAt, now)
  const people = [
    session.openedByName ? t('historyOpenedBy', { name: session.openedByName }) : '',
    session.closedAt && session.closedByName ? t('historyEndedBy', { name: session.closedByName }) : '',
  ]
    .filter(Boolean)
    .join(' · ')

  return (
    <Link
      to={`/session-history/${encodeURIComponent(session.id)}`}
      className="group block h-full rounded-xl focus-visible:ring-2 focus-visible:ring-brand-coral/60 focus-visible:ring-offset-2 focus-visible:ring-offset-brand-mist focus-visible:outline-none dark:focus-visible:ring-offset-brand-navy"
    >
      <article
        className={`flex h-full flex-col gap-2.5 rounded-xl border bg-white p-3.5 shadow-sm transition-colors group-hover:border-brand-navy/30 dark:bg-brand-navy-raised dark:shadow-none dark:group-hover:border-white/30 ${
          open
            ? 'border-emerald-500/50 dark:border-emerald-400/40'
            : 'border-brand-navy/10 dark:border-white/10'
        }`}
      >
        <header className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h2 className="flex flex-wrap items-center gap-x-2 text-sm font-semibold text-brand-navy dark:text-white">
              <CalendarIcon
                width={16}
                height={16}
                className="shrink-0 text-brand-navy/60 dark:text-white/60"
              />
              {formatDayShort(locale, session.openedAt)}
              {relativeDay ? (
                <span className="text-xs font-medium text-brand-navy/60 dark:text-white/60">{relativeDay}</span>
              ) : null}
            </h2>
            {showChamber && session.chamberName ? (
              <p className="mt-0.5 flex items-center gap-1 text-xs text-brand-navy/70 dark:text-white/70">
                <MapPinIcon width={12} height={12} className="shrink-0" />
                <span className="truncate">{session.chamberName}</span>
              </p>
            ) : null}
          </div>
          <SessionStatusPill session={session} />
        </header>

        <p className="flex flex-wrap items-center gap-x-1.5 gap-y-0.5 text-xs text-brand-navy/80 dark:text-white/80">
          <ClockIcon width={14} height={14} className="shrink-0 text-brand-navy/60 dark:text-white/60" />
          <span>{range}</span>
          <span aria-hidden="true">·</span>
          <span className="font-medium">{formatRunTime(t, session, now)}</span>
        </p>

        <div className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1">
          <p className="text-xs font-medium text-brand-navy/65 dark:text-white/65">
            {t('historyTokens')}{' '}
            <span className="text-lg font-bold text-brand-navy tabular-nums dark:text-white">
              {nf.format(totalTokens(session.counts))}
            </span>
          </p>
          {session.totalFeeBdt !== undefined ? (
            <p className="text-xs font-medium text-brand-navy/65 dark:text-white/65">
              {t('historyTotalFees')}{' '}
              <span
                className="text-lg font-bold text-brand-navy tabular-nums dark:text-white"
                data-testid="session-fees"
              >
                {formatBdt(locale, session.totalFeeBdt)}
              </span>
            </p>
          ) : null}
          {session.freeCount !== undefined ? (
            <p className="text-xs font-medium text-brand-navy/65 dark:text-white/65">
              {t('historyFree')}{' '}
              <span
                className="text-lg font-bold text-brand-navy tabular-nums dark:text-white"
                data-testid="session-free"
              >
                {nf.format(session.freeCount)}
              </span>
            </p>
          ) : null}
        </div>

        <OutcomeSummary counts={session.counts} />

        {people || reason ? (
          <footer className="mt-auto space-y-0.5 border-t border-brand-navy/10 pt-2 text-xs text-brand-navy/70 dark:border-white/10 dark:text-white/70">
            {people ? (
              <p className="flex items-center gap-1.5">
                <PersonIcon width={13} height={13} className="shrink-0" />
                <span className="min-w-0">{people}</span>
              </p>
            ) : null}
            {reason ? (
              <p className="text-orange-800 dark:text-orange-200">{t('historyReason', { reason })}</p>
            ) : null}
          </footer>
        ) : null}
      </article>
    </Link>
  )
}
