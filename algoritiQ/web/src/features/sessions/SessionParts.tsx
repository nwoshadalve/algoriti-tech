/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { SessionSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { isForceClosed, notSeen, totalTokens } from '@/features/sessions/sessionFormat'

/** "Running now" / "Ended" / "Ended by admin". */
export function SessionStatusPill({ session }: { session: SessionSummary }) {
  const { t } = useLocale()
  const open = !session.closedAt
  const forced = isForceClosed(session)
  const tone = open
    ? 'border-emerald-600/30 bg-emerald-50 text-emerald-950 dark:border-emerald-400/30 dark:bg-emerald-950/30 dark:text-emerald-100'
    : forced
      ? 'border-orange-500/35 bg-orange-50 text-orange-950 dark:border-orange-400/35 dark:bg-orange-950/30 dark:text-orange-100'
      : 'border-brand-navy/15 bg-brand-mist text-brand-navy dark:border-white/15 dark:bg-white/10 dark:text-white'
  return (
    <span
      className={`inline-flex shrink-0 items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-xs font-medium ${tone}`}
    >
      <span
        aria-hidden="true"
        className={`h-1.5 w-1.5 rounded-full bg-current ${open ? "animate-pulse" : "opacity-60"}`}
      />
      {open ? t('historyStatusOpen') : forced ? t('historyStatusForced') : t('historyStatusEnded')}
    </span>
  )
}

function Stat({ value, label }: { value: number; label: string }) {
  const { locale } = useLocale()
  return (
    <div>
      <div className="text-xl font-bold tabular-nums">{new Intl.NumberFormat(locale).format(value)}</div>
      <div className="text-xs text-brand-navy/70 dark:text-white/70">{label}</div>
    </div>
  )
}

/** Issued, seen, missed, cancelled and not seen. */
export function SessionCounts({ counts }: { counts: SessionSummary['counts'] }) {
  const { t } = useLocale()
  return (
    <div className="flex flex-wrap gap-x-6 gap-y-3">
      <Stat value={totalTokens(counts)} label={t('historyTokens')} />
      <Stat value={counts.ENTERED ?? 0} label={t('boardTokenEntered')} />
      <Stat value={counts.SKIPPED ?? 0} label={t('boardTokenSkipped')} />
      <Stat value={counts.CANCELLED ?? 0} label={t('boardTokenCancelled')} />
      <Stat value={notSeen(counts)} label={t('historyNotSeen')} />
    </div>
  )
}
