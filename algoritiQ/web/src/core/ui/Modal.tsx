/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useId, useRef, type KeyboardEvent, type ReactNode } from 'react'
import { createPortal } from 'react-dom'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { CloseIcon } from '@/core/ui/icons'
import { lockPageScroll } from '@/core/ui/scrollLock'
import { Tooltip } from '@/core/ui/Tooltip'

type ModalProps = {
  title: string
  /** One line under the title, in the header. */
  description?: string
  /** Scrolls when it is taller than the space left between the header and footer. */
  children: ReactNode
  /** Fixed at the bottom: the buttons. Leave out when the popup needs none. */
  footer?: ReactNode
  /** Close was asked for (X button, Escape, a click outside). */
  onClose: () => void
  /** While something is being saved: closing is blocked so the result is not lost. */
  busy?: boolean
  size?: 'sm' | 'md' | 'lg'
}

const widths = { sm: 'sm:max-w-sm', md: 'sm:max-w-md', lg: 'sm:max-w-lg' }

const FOCUSABLE =
  'a[href],button:not([disabled]),input:not([disabled]),select:not([disabled]),textarea:not([disabled]),[tabindex]:not([tabindex="-1"])'

/**
 * A popup with a fixed header (title and close button), a scrolling body and an
 * optional fixed footer for the buttons. A centred card from `sm` up; a sheet
 * that rises from the bottom on phones. Render it only while it is open: its
 * state starts fresh each time. Focus is kept inside, and goes back to what
 * opened it on close.
 */
export function Modal({
  title,
  description,
  children,
  footer,
  onClose,
  busy = false,
  size = 'md',
}: ModalProps) {
  const { t } = useLocale()
  const titleId = useId()
  const descriptionId = useId()
  const panel = useRef<HTMLDivElement>(null)
  const body = useRef<HTMLDivElement>(null)
  const latest = useRef({ onClose, busy })

  useEffect(() => {
    latest.current = { onClose, busy }
  })

  useEffect(() => {
    const opener = document.activeElement as HTMLElement | null
    const release = lockPageScroll()
    const first = body.current?.querySelector<HTMLElement>(FOCUSABLE) ?? panel.current
    first?.focus()
    return () => {
      release()
      opener?.focus?.()
    }
  }, [])

  useEffect(() => {
    const onKeyDown = (event: globalThis.KeyboardEvent) => {
      if (event.key === 'Escape' && !latest.current.busy) {
        event.stopPropagation()
        latest.current.onClose()
      }
    }
    document.addEventListener('keydown', onKeyDown)
    return () => document.removeEventListener('keydown', onKeyDown)
  }, [])

  // Tab and Shift+Tab go round inside the popup.
  function onKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    if (event.key !== 'Tab' || !panel.current) return
    const items = [...panel.current.querySelectorAll<HTMLElement>(FOCUSABLE)]
    if (items.length === 0) {
      event.preventDefault()
      return
    }
    const first = items[0]
    const last = items[items.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  return createPortal(
    <div
      className="fixed inset-0 z-[70] flex items-end justify-center bg-brand-navy/60 backdrop-blur-[2px] sm:items-center sm:p-6"
      // Pressing on the dark area closes it; pressing inside and dragging out does not.
      onPointerDown={(event) => {
        if (event.target === event.currentTarget && !busy) onClose()
      }}
    >
      <div
        ref={panel}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        aria-describedby={description ? descriptionId : undefined}
        tabIndex={-1}
        onKeyDown={onKeyDown}
        className={[
          'modal-enter flex w-full flex-col overflow-hidden bg-white text-brand-navy shadow-2xl outline-none dark:bg-brand-navy-raised dark:text-white',
          'max-h-[calc(100dvh-0.75rem)] rounded-t-2xl sm:max-h-[min(42rem,calc(100dvh-3rem))] sm:rounded-2xl',
          'border border-brand-navy/10 dark:border-white/10',
          widths[size],
        ].join(' ')}
      >
        <header className="flex shrink-0 items-start gap-3 border-b border-brand-navy/10 px-5 py-4 dark:border-white/10">
          <div className="min-w-0 flex-1">
            <h2 id={titleId} className="text-lg font-semibold">
              {title}
            </h2>
            {description ? (
              <p
                id={descriptionId}
                className="mt-1 text-sm text-brand-navy/70 dark:text-white/70"
              >
                {description}
              </p>
            ) : null}
          </div>
          <Tooltip label={t('modalClose')}>
            {!busy ? (
              <button
                type="button"
                aria-label={t('modalClose')}
                onClick={onClose}
                className="-mt-1 -mr-2 flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-brand-navy/70 transition-colors hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:text-white/70 dark:hover:bg-white/10"
              >
                <CloseIcon />
              </button>
            ) : (
              <span className="h-11 w-11 shrink-0" aria-hidden />
            )}
          </Tooltip>
        </header>

        <div
          ref={body}
          data-testid="modal-body"
          className="min-h-0 flex-1 overflow-y-auto overscroll-contain px-5 py-4"
        >
          {children}
        </div>

        {footer ? (
          <footer className="flex shrink-0 flex-col-reverse gap-2 border-t border-brand-navy/10 px-5 pt-4 pb-[max(1rem,env(safe-area-inset-bottom))] sm:flex-row sm:items-center sm:justify-end sm:pb-4 dark:border-white/10">
            {footer}
          </footer>
        ) : null}
      </div>
    </div>,
    document.body,
  )
}
