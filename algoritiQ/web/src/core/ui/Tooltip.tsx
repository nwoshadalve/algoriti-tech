/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useId, useLayoutEffect, useRef, useState, type ReactNode } from 'react'
import { createPortal } from 'react-dom'

type TooltipProps = {
  /** The words shown. Keep them to a few: the name of the action. */
  label: string
  children: ReactNode
  placement?: 'top' | 'bottom'
}

const HOVER_DELAY_MS = 350
const GAP = 8
const EDGE = 8

/**
 * A small label above (or below) a control, shown on hover after a short pause
 * and at once on keyboard focus. Escape, leaving, clicking or scrolling hides it.
 * It sits on the page rather than inside the control's container, so a table or
 * card with `overflow: hidden` cannot cut it off.
 *
 * The control must carry its own accessible name (`aria-label`); the tooltip is
 * a visual help and is hidden from screen readers so nothing is read twice.
 */
export function Tooltip({ label, children, placement = 'top' }: TooltipProps) {
  const id = useId()
  const anchor = useRef<HTMLSpanElement>(null)
  const bubble = useRef<HTMLDivElement>(null)
  const timer = useRef<number | undefined>(undefined)
  const [open, setOpen] = useState(false)
  const [position, setPosition] = useState<{ left: number; top: number } | null>(null)

  const show = useCallback((delay: number) => {
    window.clearTimeout(timer.current)
    timer.current = window.setTimeout(() => setOpen(true), delay)
  }, [])

  const hide = useCallback(() => {
    window.clearTimeout(timer.current)
    setOpen(false)
    setPosition(null)
  }, [])

  useEffect(() => () => window.clearTimeout(timer.current), [])

  useEffect(() => {
    if (!open) return
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') hide()
    }
    document.addEventListener('keydown', onKeyDown)
    window.addEventListener('scroll', hide, true)
    window.addEventListener('resize', hide)
    return () => {
      document.removeEventListener('keydown', onKeyDown)
      window.removeEventListener('scroll', hide, true)
      window.removeEventListener('resize', hide)
    }
  }, [open, hide])

  // Placed once it is on screen and its size is known; kept inside the window.
  useLayoutEffect(() => {
    if (!open || !anchor.current || !bubble.current) return
    const rect = anchor.current.getBoundingClientRect()
    const size = bubble.current.getBoundingClientRect()
    const centre = rect.left + rect.width / 2
    const left = Math.min(
      Math.max(EDGE, centre - size.width / 2),
      Math.max(EDGE, window.innerWidth - size.width - EDGE),
    )
    const above = placement === 'top' && rect.top - size.height - GAP >= EDGE
    setPosition({
      left,
      top: above || placement === 'top' ? rect.top - size.height - GAP : rect.bottom + GAP,
    })
  }, [open, placement, label])

  return (
    <span
      ref={anchor}
      className="inline-flex"
      onMouseEnter={() => show(HOVER_DELAY_MS)}
      onMouseLeave={hide}
      onFocus={() => show(0)}
      onBlur={hide}
      onClick={hide}
    >
      {children}
      {open
        ? createPortal(
            <div
              ref={bubble}
              id={id}
              role="tooltip"
              aria-hidden="true"
              style={{
                left: position?.left ?? 0,
                top: position?.top ?? 0,
                visibility: position ? 'visible' : 'hidden',
              }}
              className="pointer-events-none fixed z-[90] max-w-64 rounded-lg bg-brand-navy px-2.5 py-1.5 text-xs leading-snug font-medium text-white shadow-lg ring-1 ring-white/10 dark:bg-white dark:text-brand-navy dark:ring-brand-navy/10"
            >
              {label}
            </div>,
            document.body,
          )
        : null}
    </span>
  )
}
