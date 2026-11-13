/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { KeyboardEvent } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

export type QueueDeskTab = 'calling' | 'patients'

const order: QueueDeskTab[] = ['calling', 'patients']

export const queueDeskTabId = (tab: QueueDeskTab) => `desk-tab-${tab}`
export const queueDeskPanelId = (tab: QueueDeskTab) => `desk-panel-${tab}`

type QueueDeskTabsProps = {
  selected: QueueDeskTab
  onSelect: (tab: QueueDeskTab) => void
  calling: number
  patients: number
}

/** The desk's two tabs with how many calls and patients each holds (same split as the tablet). */
export function QueueDeskTabs({ selected, onSelect, calling, patients }: QueueDeskTabsProps) {
  const { t, locale } = useLocale()
  const counts: Record<QueueDeskTab, number> = { calling, patients }
  const labels: Record<QueueDeskTab, string> = {
    calling: t('boardTabCalling'),
    patients: t('boardTabPatients'),
  }

  function onKeyDown(event: KeyboardEvent<HTMLButtonElement>, tab: QueueDeskTab) {
    const step = event.key === 'ArrowRight' ? 1 : event.key === 'ArrowLeft' ? -1 : 0
    if (step === 0) return
    event.preventDefault()
    const next = order[(order.indexOf(tab) + step + order.length) % order.length]!
    onSelect(next)
    document.getElementById(queueDeskTabId(next))?.focus()
  }

  return (
    <div
      role="tablist"
      aria-label={t('boardDeskTabsLabel')}
      className="inline-flex w-full overflow-hidden rounded-xl border border-brand-navy/15 bg-white sm:w-auto dark:border-white/15 dark:bg-brand-navy-raised"
    >
      {order.map((tab) => {
        const active = tab === selected
        return (
          <button
            key={tab}
            id={queueDeskTabId(tab)}
            type="button"
            role="tab"
            aria-selected={active}
            aria-controls={queueDeskPanelId(tab)}
            tabIndex={active ? 0 : -1}
            onClick={() => onSelect(tab)}
            onKeyDown={(event) => onKeyDown(event, tab)}
            className={`min-h-11 flex-1 px-5 text-sm font-semibold transition-colors focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none focus-visible:ring-inset sm:flex-none ${
              active
                ? 'bg-brand-coral-action/15 text-brand-coral-action dark:bg-brand-coral/20 dark:text-white'
                : 'text-brand-navy/75 hover:bg-brand-mist dark:text-white/75 dark:hover:bg-white/10'
            }`}
          >
            {labels[tab]} <span className="tabular-nums">{formatQueueSerial(counts[tab], locale)}</span>
          </button>
        )
      })}
    </div>
  )
}
