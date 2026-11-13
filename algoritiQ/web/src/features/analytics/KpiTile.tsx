/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, ReactNode, SVGProps } from 'react'
import { Sparkline } from '@/features/analytics/charts/Sparkline'

type KpiTileProps = {
  icon: ComponentType<SVGProps<SVGSVGElement>>
  label: string
  value: ReactNode
  /** Under the figure: usually a `Delta`, or a short note. */
  footer?: ReactNode
  /** The recent values, drawn as a small trend line. */
  trend?: number[]
  /** A CSS colour for the trend line, normally a `var(--viz-n)`. */
  color?: string
  testId?: string
}

/** One headline figure: a quiet label, a large value, how it moved and, optionally, a trend line. */
export function KpiTile({ icon: Icon, label, value, footer, trend, color = 'var(--viz-1)', testId }: KpiTileProps) {
  return (
    <div className="flex min-w-0 flex-col gap-2 rounded-xl border border-brand-navy/10 bg-white p-4 shadow-sm dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none">
      <p className="flex items-center gap-2 text-xs font-medium text-brand-navy/70 dark:text-white/70">
        <Icon width={16} height={16} className="shrink-0" />
        <span className="truncate">{label}</span>
      </p>
      <p className="text-2xl leading-tight font-bold" data-testid={testId}>
        {value}
      </p>
      {trend ? (
        <div className="pr-1">
          <Sparkline values={trend} color={color} />
        </div>
      ) : null}
      {footer ? <div className="mt-auto min-h-4">{footer}</div> : null}
    </div>
  )
}
