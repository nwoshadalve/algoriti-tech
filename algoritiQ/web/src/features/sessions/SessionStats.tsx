/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ReactNode } from 'react'
import type { SessionSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { outcomeTone, type OutcomeTone } from '@/features/sessions/outcomeTone'
import { notSeen, totalTokens } from '@/features/sessions/sessionFormat'

/** One bar showing how the session's tokens ended. */
export function OutcomeBar({ counts }: { counts: SessionSummary['counts'] }) {
  const total = totalTokens(counts)
  const parts: { tone: OutcomeTone; value: number }[] = [
    { tone: 'seen', value: counts.ENTERED ?? 0 },
    { tone: 'missed', value: counts.SKIPPED ?? 0 },
    { tone: 'waiting', value: notSeen(counts) },
    { tone: 'cancelled', value: counts.CANCELLED ?? 0 },
  ]
  return (
    <div
      aria-hidden="true"
      className="flex h-1.5 w-full overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/10"
    >
      {total > 0
        ? parts
            .filter((part) => part.value > 0)
            .map((part) => (
              <div
                key={part.tone}
                className={outcomeTone[part.tone].bar}
                style={{ width: `${(part.value / total) * 100}%` }}
              />
            ))
        : null}
    </div>
  )
}

/** One outcome as a coloured dot, its number and its name. Zero is dimmed. */
export function OutcomeItem({ tone, value, label }: { tone: OutcomeTone; value: number; label: string }) {
  const { locale } = useLocale()
  const none = value === 0
  return (
    <span className={`inline-flex items-center gap-1.5 whitespace-nowrap ${none ? 'opacity-50' : ''}`}>
      <span aria-hidden="true" className={`h-2 w-2 shrink-0 rounded-full ${outcomeTone[tone].bar}`} />
      <span className="font-semibold tabular-nums">{new Intl.NumberFormat(locale).format(value)}</span>
      <span className="text-brand-navy/70 dark:text-white/70">{label}</span>
    </span>
  )
}

/** The four outcomes on one line (wrapping when narrow). */
export function OutcomeLegend({ counts }: { counts: SessionSummary['counts'] }) {
  const { t } = useLocale()
  return (
    <div className="flex flex-wrap gap-x-4 gap-y-1 text-xs">
      <OutcomeItem tone="seen" value={counts.ENTERED ?? 0} label={t('boardTokenEntered')} />
      <OutcomeItem tone="missed" value={counts.SKIPPED ?? 0} label={t('boardTokenSkipped')} />
      <OutcomeItem tone="cancelled" value={counts.CANCELLED ?? 0} label={t('boardTokenCancelled')} />
      <OutcomeItem tone="waiting" value={notSeen(counts)} label={t('historyNotSeen')} />
    </div>
  )
}

/** The bar and, under it, the four outcomes: how the session ended, in two thin lines. */
export function OutcomeSummary({ counts }: { counts: SessionSummary['counts'] }) {
  return (
    <div className="space-y-2">
      <OutcomeBar counts={counts} />
      <OutcomeLegend counts={counts} />
    </div>
  )
}

/** A figure with a small caption above it, used for totals such as tokens and fees. */
export function Figure({
  label,
  children,
  align = 'left',
}: {
  label: string
  children: ReactNode
  align?: 'left' | 'right'
}) {
  return (
    <div className={align === 'right' ? 'text-right' : ''}>
      <p className="text-xs font-medium text-brand-navy/65 dark:text-white/65">{label}</p>
      <p className="text-xl leading-tight font-bold tabular-nums">{children}</p>
    </div>
  )
}
