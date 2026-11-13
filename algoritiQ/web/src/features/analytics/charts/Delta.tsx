/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

type DeltaProps = {
  /** The change as a fraction (0.12 is up 12%), or null when there is nothing to compare. */
  change: number | null
  /** What the change is against, e.g. "yesterday". */
  caption: string
  /** False for a figure where going up is bad (waiting time, cancellations). */
  goodWhenUp?: boolean
}

/** "+12% vs yesterday": signed, green when it is good news, red when it is not, plain when flat. */
export function Delta({ change, caption, goodWhenUp = true }: DeltaProps) {
  const { locale } = useLocale()
  if (change === null) return <span className="text-xs text-brand-navy/55 dark:text-white/55">{caption}</span>

  const rounded = Math.round(change * 100)
  const flat = rounded === 0
  const good = rounded > 0 === goodWhenUp
  const tone = flat
    ? 'text-brand-navy/70 dark:text-white/70'
    : good
      ? 'text-emerald-700 dark:text-emerald-400'
      : 'text-red-700 dark:text-red-400'
  const sign = rounded > 0 ? '+' : rounded < 0 ? '−' : ''
  return (
    <span className="text-xs text-brand-navy/65 dark:text-white/65">
      <span className={`font-semibold tabular-nums ${tone}`}>
        {sign}
        {new Intl.NumberFormat(locale).format(Math.abs(rounded))}%
      </span>{' '}
      {caption}
    </span>
  )
}
