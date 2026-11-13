/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ReactNode } from 'react'

export type BarRow = {
  key: string
  label: string
  value: number
  /** The value as shown, at the end of the bar. */
  display: string
  /** A smaller second line, e.g. the fees of that row. */
  note?: ReactNode
}

/** One bar per row, longest first: a name, a thin bar and the value at its tip. */
export function BarList({ rows, color }: { rows: BarRow[]; color: string }) {
  const max = Math.max(1, ...rows.map((row) => row.value))
  return (
    <ul className="space-y-3">
      {rows.map((row) => (
        <li key={row.key}>
          <div className="flex items-baseline justify-between gap-3 text-sm">
            <span className="min-w-0 truncate font-medium">{row.label}</span>
            <span className="shrink-0 font-semibold tabular-nums">{row.display}</span>
          </div>
          <div
            aria-hidden="true"
            className="mt-1.5 h-2 w-full overflow-hidden rounded-full bg-brand-navy/10 dark:bg-white/10"
          >
            <div
              className="h-full rounded-full"
              style={{ width: `${(row.value / max) * 100}%`, backgroundColor: color }}
            />
          </div>
          {row.note ? <p className="mt-1 text-xs text-brand-navy/65 dark:text-white/65">{row.note}</p> : null}
        </li>
      ))}
    </ul>
  )
}
