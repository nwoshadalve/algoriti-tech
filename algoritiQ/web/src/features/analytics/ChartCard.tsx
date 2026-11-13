/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useId, useState } from 'react'
import type { ReactNode } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'

type ChartCardProps = {
  title: string
  subtitle?: string
  children: ReactNode
  /** When given, the card can swap its chart for these rows: the same figures as text. */
  table?: { columns: string[]; rows: string[][] }
  className?: string
}

/** A panel for one chart: title, optional subtitle and a chart/table switch for readers who want the numbers. */
export function ChartCard({ title, subtitle, children, table, className = '' }: ChartCardProps) {
  const { t } = useLocale()
  const [asTable, setAsTable] = useState(false)
  const id = useId()

  return (
    <section
      aria-labelledby={id}
      className={`min-w-0 rounded-xl border border-brand-navy/10 bg-white p-4 shadow-sm sm:p-5 dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none ${className}`}
    >
      <div className="mb-4 flex flex-wrap items-start justify-between gap-x-3 gap-y-1">
        <div className="min-w-0">
          <h2 id={id} className="font-semibold">
            {title}
          </h2>
          {subtitle ? <p className="text-xs text-brand-navy/65 dark:text-white/65">{subtitle}</p> : null}
        </div>
        {table ? (
          <button
            type="button"
            aria-pressed={asTable}
            onClick={() => setAsTable((current) => !current)}
            className="min-h-9 rounded-lg border border-brand-navy/15 px-3 text-xs font-semibold hover:bg-brand-mist focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:border-white/20 dark:hover:bg-white/10"
          >
            {asTable ? t('analyticsViewChart') : t('analyticsViewTable')}
          </button>
        ) : null}
      </div>

      {table && asTable ? (
        <div className="max-h-72 overflow-auto rounded-lg border border-brand-navy/10 dark:border-white/10">
          <table className="w-full min-w-0 text-left text-sm">
            <thead className="sticky top-0 bg-brand-mist text-xs text-brand-navy/70 uppercase dark:bg-brand-navy dark:text-white/70">
              <tr>
                {table.columns.map((column, index) => (
                  <th key={column} scope="col" className={`px-3 py-2 font-semibold ${index > 0 ? 'text-right' : ''}`}>
                    {column}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {table.rows.map((row) => (
                <tr key={row[0]} className="border-t border-brand-navy/8 dark:border-white/10">
                  {row.map((cell, index) => (
                    <td key={index} className={`px-3 py-2 tabular-nums ${index > 0 ? 'text-right' : ''}`}>
                      {cell}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        children
      )}
    </section>
  )
}
