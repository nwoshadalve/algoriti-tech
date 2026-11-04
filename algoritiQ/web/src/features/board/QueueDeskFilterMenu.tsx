/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useRef, useState } from 'react'

export type DeskFilterChoice<T> = { value: T | null; label: string }

type QueueDeskFilterMenuProps<T> = {
  tooltip: string
  selected: T | null
  choices: DeskFilterChoice<T>[]
  onSelected: (value: T | null) => void
}

/** Outlined dropdown filter — matches tablet [DeskFilterMenu]. */
export function QueueDeskFilterMenu<T extends string>({
  tooltip,
  selected,
  choices,
  onSelected,
}: QueueDeskFilterMenuProps<T>) {
  const [open, setOpen] = useState(false)
  const rootRef = useRef<HTMLDivElement>(null)
  const current = choices.find((row) => row.value === selected) ?? choices[0]!

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
        title={tooltip}
        aria-haspopup="listbox"
        aria-expanded={open}
        className={[
          'inline-flex min-h-10 max-w-full items-center gap-1 rounded-xl border px-3 py-2 text-sm font-medium',
          selected == null
            ? 'border-brand-navy/15 bg-white text-brand-navy dark:border-white/15 dark:bg-brand-navy-raised dark:text-white'
            : 'border-brand-coral-action bg-brand-coral-action/5 text-brand-navy dark:text-white',
        ].join(' ')}
        onClick={() => setOpen((value) => !value)}
      >
        <span className="truncate">{current.label}</span>
        <span aria-hidden className="text-brand-navy/50 dark:text-white/50">
          ▾
        </span>
      </button>
      {open ? (
        <ul
          role="listbox"
          className="absolute top-full left-0 z-30 mt-1 max-h-64 min-w-[12rem] overflow-y-auto rounded-xl border border-brand-navy/10 bg-white py-1 shadow-lg dark:border-white/10 dark:bg-brand-navy-raised"
        >
          {choices.map((row) => {
            const active = row.value === selected
            return (
              <li key={row.value ?? '__all'} role="option" aria-selected={active}>
                <button
                  type="button"
                  className={[
                    'flex w-full items-center gap-2 px-4 py-2.5 text-left text-sm hover:bg-brand-mist dark:hover:bg-white/5',
                    active ? 'font-semibold text-brand-coral-action' : '',
                  ].join(' ')}
                  onClick={() => {
                    onSelected(row.value)
                    setOpen(false)
                  }}
                >
                  {active ? <span aria-hidden>✓</span> : <span className="w-3" aria-hidden />}
                  {row.label}
                </button>
              </li>
            )
          })}
        </ul>
      ) : null}
    </div>
  )
}
