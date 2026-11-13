/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ticks } from '@/features/analytics/analyticsFormat'

export type Column = {
  key: string
  /** Short, for the axis. */
  label: string
  /** Full, for the tooltip and the screen reader. */
  title: string
  value: number
  /** The value as shown, e.g. "৳12,500". */
  display: string
}

type ColumnChartProps = {
  columns: Column[]
  /** A CSS colour, normally a `var(--viz-n)`. */
  color: string
  /** Names the chart for a screen reader. */
  ariaLabel: string
  /** Axis tick text for a value. */
  formatTick: (value: number) => string
  /** Plot height in rem. */
  heightRem?: number
}

/** How many axis labels fit: every point up to 12, else about eight. */
function labelStep(count: number): number {
  return count <= 12 ? 1 : Math.ceil(count / 8)
}

/**
 * Columns from one baseline: thin, rounded at the top, a 2px gap between them,
 * hairline gridlines, the tallest labelled on its cap, a tooltip on hover or
 * keyboard focus. Plain HTML, so the text stays crisp and wraps with the page.
 */
export function ColumnChart({ columns, color, ariaLabel, formatTick, heightRem = 11 }: ColumnChartProps) {
  const max = Math.max(0, ...columns.map((c) => c.value))
  const axis = ticks(max)
  const top = axis[axis.length - 1]!
  const step = labelStep(columns.length)
  const tallest = max > 0 ? columns.findIndex((c) => c.value === max) : -1

  return (
    <div className="flex gap-2" role="group" aria-label={ariaLabel}>
      {/* Value axis: round numbers, top to bottom. */}
      <div
        aria-hidden="true"
        className="flex shrink-0 flex-col-reverse justify-between pb-6 text-right text-[11px] leading-none text-brand-navy/60 tabular-nums dark:text-white/60"
        style={{ height: `${heightRem + 1.5}rem` }}
      >
        {axis.map((tick) => (
          <span key={tick} className="min-w-8">
            {formatTick(tick)}
          </span>
        ))}
      </div>

      <div className="min-w-0 flex-1">
        <div className="relative" style={{ height: `${heightRem}rem` }}>
          {axis.map((tick, index) => (
            <div
              key={tick}
              aria-hidden="true"
              className="absolute inset-x-0 border-t"
              style={{
                bottom: `${(tick / top) * 100}%`,
                borderColor: index === 0 ? 'var(--viz-axis)' : 'var(--viz-grid)',
              }}
            />
          ))}

          <ul className="absolute inset-0 flex items-end gap-[2px]">
            {columns.map((column, index) => {
              const edge = index < columns.length * 0.2 ? 'left' : index > columns.length * 0.8 ? 'right' : 'middle'
              return (
                <li key={column.key} className="group relative flex h-full min-w-0 flex-1 items-end justify-center">
                  <button
                    type="button"
                    aria-label={`${column.title}: ${column.display}`}
                    className="flex h-full w-full items-end justify-center rounded-sm focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                  >
                    <span
                      className="block w-full max-w-6 rounded-t-[4px] transition-opacity group-hover:opacity-80"
                      style={{
                        backgroundColor: color,
                        height: column.value > 0 ? `max(${(column.value / top) * 100}%, 3px)` : '0',
                      }}
                    />
                  </button>

                  {index === tallest ? (
                    <span
                      aria-hidden="true"
                      className="pointer-events-none absolute left-1/2 -translate-x-1/2 text-[11px] font-semibold whitespace-nowrap text-brand-navy dark:text-white"
                      style={{ bottom: `calc(${(column.value / top) * 100}% + 4px)` }}
                    >
                      {column.display}
                    </span>
                  ) : null}

                  <div
                    role="tooltip"
                    className={`pointer-events-none absolute bottom-full z-20 mb-2 hidden rounded-lg border border-brand-navy/10 bg-white px-2.5 py-1.5 text-xs whitespace-nowrap shadow-md group-focus-within:block group-hover:block dark:border-white/15 dark:bg-brand-navy-raised ${
                      edge === 'left' ? 'left-0' : edge === 'right' ? 'right-0' : 'left-1/2 -translate-x-1/2'
                    }`}
                  >
                    <span className="block text-brand-navy/70 dark:text-white/70">{column.title}</span>
                    <span className="flex items-center gap-1.5 font-semibold text-brand-navy dark:text-white">
                      <span aria-hidden="true" className="h-2 w-2 rounded-full" style={{ backgroundColor: color }} />
                      {column.display}
                    </span>
                  </div>
                </li>
              )
            })}
          </ul>
        </div>

        <ul aria-hidden="true" className="mt-1.5 flex h-4 gap-[2px] text-[11px] leading-none text-brand-navy/60 dark:text-white/60">
          {columns.map((column, index) => (
            <li key={column.key} className="relative min-w-0 flex-1 text-center">
              {index % step === 0 ? (
                <span className="absolute left-1/2 -translate-x-1/2 whitespace-nowrap">{column.label}</span>
              ) : null}
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}
