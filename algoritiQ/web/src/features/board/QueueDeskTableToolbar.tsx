/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useRef, useState } from 'react'
import type { MessageKey } from '@/core/i18n/messages/types'
import type { QueueTypeBoardControl, TokenSort, TokenStatus } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { TextField } from '@/core/ui/TextField'
import { queueDisplayName, tokenStatusLabelKey } from '@/features/board/boardFormat'
import { QueueDeskFilterMenu } from '@/features/board/QueueDeskFilterMenu'

const statusOrder: TokenStatus[] = ['WAITING', 'CALLED', 'SKIPPED', 'ENTERED', 'CANCELLED']

const sortColumns: { sort: TokenSort; column: SortableColumn }[] = [
  { sort: 'issued', column: 'serial' },
  { sort: 'id', column: 'id' },
  { sort: 'name', column: 'name' },
  { sort: 'serial', column: 'serial' },
  { sort: 'queue', column: 'queue' },
  { sort: 'wait', column: 'wait' },
  { sort: 'status', column: 'status' },
]

type QueueDeskTableToolbarProps = {
  search: string
  onSearchChange: (value: string) => void
  status: TokenStatus | null
  onStatusChange: (status: TokenStatus | null) => void
  queueTypeId: string | null
  onQueueChange: (queueTypeId: string | null) => void
  notPrintedOnly: boolean
  onToggleNotPrinted: () => void
  sort: TokenSort
  ascending: boolean
  onSort: (sort: TokenSort) => void
  counts: Partial<Record<TokenStatus, number>>
  total: number
  queues: QueueTypeBoardControl[]
  hasFilters: boolean
  onClear: () => void
}

function DeskSortMenu({
  sort,
  ascending,
  onSort,
}: {
  sort: TokenSort
  ascending: boolean
  onSort: (sort: TokenSort) => void
}) {
  const { t } = useLocale()
  const [open, setOpen] = useState(false)
  const rootRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    function onPointerDown(event: MouseEvent) {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', onPointerDown)
    return () => document.removeEventListener('mousedown', onPointerDown)
  }, [open])

  return (
    <div ref={rootRef} className="relative">
      <button
        type="button"
        title={t('boardSortBy')}
        aria-haspopup="menu"
        aria-expanded={open}
        className="inline-flex min-h-10 min-w-10 items-center justify-center rounded-xl border border-brand-navy/15 bg-white text-brand-navy dark:border-white/15 dark:bg-brand-navy-raised dark:text-white"
        onClick={() => setOpen((value) => !value)}
      >
        <span
          aria-hidden
          className="text-lg leading-none"
          style={{ display: 'inline-block', transform: ascending ? 'scaleY(1)' : 'scaleY(-1)' }}
        >
          ⇅
        </span>
      </button>
      {open ? (
        <ul
          role="menu"
          className="absolute top-full right-0 z-30 mt-1 min-w-[11rem] rounded-xl border border-brand-navy/10 bg-white py-1 shadow-lg dark:border-white/10 dark:bg-brand-navy-raised"
        >
          {sortColumns.map(({ sort: key, column }) => {
            const active = sort === key
            const label = key === 'issued' ? t('boardColIssued') : sortHeadingLabel(t, column)
            return (
              <li key={key} role="none">
                <button
                  type="button"
                  role="menuitemradio"
                  aria-checked={active}
                  className={[
                    'flex w-full items-center gap-2 px-4 py-2.5 text-left text-sm hover:bg-brand-mist dark:hover:bg-white/5',
                    active ? 'font-semibold text-brand-coral-action' : '',
                  ].join(' ')}
                  onClick={() => {
                    onSort(key)
                    setOpen(false)
                  }}
                >
                  {active ? <span aria-hidden>✓</span> : <span className="w-3" aria-hidden />}
                  {label}
                </button>
              </li>
            )
          })}
        </ul>
      ) : null}
    </div>
  )
}

/** Search plus filter menus — matches tablet desk toolbar. */
export function QueueDeskTableToolbar({
  search,
  onSearchChange,
  status,
  onStatusChange,
  queueTypeId,
  onQueueChange,
  notPrintedOnly,
  onToggleNotPrinted,
  sort,
  ascending,
  onSort,
  counts,
  total,
  queues,
  hasFilters,
  onClear,
}: QueueDeskTableToolbarProps) {
  const { t, locale } = useLocale()

  const totalCount = statusOrder.reduce((sum, key) => sum + (counts[key] ?? 0), 0) || total

  const queueChoices = [
    { value: null as string | null, label: t('boardFilterAllQueues') },
    ...queues.map((row) => ({
      value: row.queueTypeId as string | null,
      label: queueDisplayName(locale, row.englishName, row.bengaliName),
    })),
  ]

  const statusChoices = [
    { value: null as TokenStatus | null, label: `${t('boardFilterAllStatuses')} ${totalCount}` },
    ...statusOrder.map((key) => ({
      value: key as TokenStatus | null,
      label: `${t(tokenStatusLabelKey[key])} ${counts[key] ?? 0}`,
    })),
  ]

  return (
    <div className="flex min-w-0 flex-col gap-3 border-b border-brand-navy/10 px-3 py-3 dark:border-white/10 sm:px-4">
      <TextField
        id="desk-session-search"
        label={t('boardDeskSearchLabel')}
        value={search}
        onChange={(event) => onSearchChange(event.target.value)}
        placeholder={t('boardDeskSearchHint')}
        autoComplete="off"
        className="w-full min-w-0"
      />

      <div className="flex flex-wrap items-center gap-2">
        <QueueDeskFilterMenu
          tooltip={t('boardColQueue')}
          selected={queueTypeId}
          choices={queueChoices}
          onSelected={onQueueChange}
        />
        <QueueDeskFilterMenu
          tooltip={t('boardColStatus')}
          selected={status}
          choices={statusChoices}
          onSelected={onStatusChange}
        />
        <button
          type="button"
          aria-pressed={notPrintedOnly}
          className={[
            'inline-flex min-h-10 items-center rounded-full border px-3 py-2 text-sm font-medium',
            notPrintedOnly
              ? 'border-brand-coral-action bg-brand-coral-action text-white'
              : 'border-brand-navy/15 bg-white text-brand-navy dark:border-white/15 dark:bg-brand-navy-raised dark:text-white',
          ].join(' ')}
          onClick={onToggleNotPrinted}
        >
          {t('boardFilterNotPrinted')}
        </button>
        <DeskSortMenu sort={sort} ascending={ascending} onSort={onSort} />
        {hasFilters ? (
          <button
            type="button"
            title={t('boardClearFilters')}
            aria-label={t('boardClearFilters')}
            className="inline-flex min-h-10 min-w-10 items-center justify-center rounded-xl border border-brand-navy/15 text-brand-navy dark:border-white/15 dark:text-white"
            onClick={onClear}
          >
            <span aria-hidden>⌀</span>
          </button>
        ) : null}
      </div>
    </div>
  )
}

export type SortableColumn = 'id' | 'name' | 'serial' | 'queue' | 'wait' | 'status'

export function sortHeadingLabel(t: (key: MessageKey) => string, column: SortableColumn): string {
  switch (column) {
    case 'id':
      return t('boardColPatientId')
    case 'name':
      return t('boardColName')
    case 'serial':
      return t('boardColSerial')
    case 'queue':
      return t('boardColQueue')
    case 'wait':
      return t('boardColWaiting')
    case 'status':
      return t('boardColStatus')
  }
}
