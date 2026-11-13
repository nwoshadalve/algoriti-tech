/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** A small trend line with a dot on the latest point. Decorative: the figure beside it says the number. */
export function Sparkline({ values, color }: { values: number[]; color: string }) {
  if (values.length < 2) return null
  const max = Math.max(...values)
  const min = Math.min(...values)
  const span = max - min || 1
  // Leave room at the edges so the line and the dot are never cut off.
  const x = (i: number) => (i / (values.length - 1)) * 100
  const y = (v: number) => 4 + (1 - (v - min) / span) * 20
  const points = values.map((v, i) => `${x(i).toFixed(2)},${y(v).toFixed(2)}`).join(' ')
  const last = values[values.length - 1]!

  return (
    <div aria-hidden="true" className="relative h-7 w-full">
      <svg viewBox="0 0 100 28" preserveAspectRatio="none" className="absolute inset-0 h-full w-full overflow-visible">
        <polyline
          points={points}
          fill="none"
          stroke={color}
          strokeWidth={2}
          strokeLinecap="round"
          strokeLinejoin="round"
          vectorEffect="non-scaling-stroke"
        />
      </svg>
      <span
        className="absolute h-2 w-2 -translate-x-1/2 -translate-y-1/2 rounded-full ring-2 ring-white dark:ring-brand-navy-raised"
        style={{ left: '100%', top: `${(y(last) / 28) * 100}%`, backgroundColor: color }}
      />
    </div>
  )
}
