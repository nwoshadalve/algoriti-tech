/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useLayoutEffect, useRef, useState } from 'react'
import type { BoardTokenView } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { IconButton } from '@/core/ui/IconButton'
import { MenuIcon, PrinterIcon } from '@/core/ui/icons'
import { BrandLoader } from '@/core/ui/BrandLoader'

type TokenRowActionsProps = {
  token: BoardTokenView
  printerBusy: boolean
  onPrint: (token: BoardTokenView) => void
  onReprint: (token: BoardTokenView) => void
  onEditPatient: (token: BoardTokenView) => void
  onCancel: (token: BoardTokenView) => void
  className?: string
}

function inQueueForPrint(status: BoardTokenView['status']): boolean {
  return status === 'WAITING' || status === 'CALLED'
}

function activeToken(status: BoardTokenView['status']): boolean {
  return status === 'WAITING' || status === 'CALLED' || status === 'SKIPPED'
}

const menuEstimatePx = 168

/** Print icon and overflow menu for one session row. */
export function TokenRowActions({
  token,
  printerBusy,
  onPrint,
  onReprint,
  onEditPatient,
  onCancel,
  className,
}: TokenRowActionsProps) {
  const { t } = useLocale()
  const [open, setOpen] = useState(false)
  // Where the menu sits on screen. It is fixed to the screen, not to the row, so the
  // table's edges (which hide anything that sticks out) cannot cut it off.
  const [menuPos, setMenuPos] = useState<{ right: number; top?: number; bottom?: number } | null>(null)
  const rootRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!open) return
    function onPointerDown(event: MouseEvent) {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false)
    }
    // The menu does not follow its row, so any scroll or resize closes it.
    const close = () => setOpen(false)
    document.addEventListener('mousedown', onPointerDown)
    window.addEventListener('scroll', close, true)
    window.addEventListener('resize', close)
    return () => {
      document.removeEventListener('mousedown', onPointerDown)
      window.removeEventListener('scroll', close, true)
      window.removeEventListener('resize', close)
    }
  }, [open])

  useLayoutEffect(() => {
    if (!open || !rootRef.current) return
    const rect = rootRef.current.getBoundingClientRect()
    const spaceBelow = window.innerHeight - rect.bottom
    const spaceAbove = rect.top
    const right = Math.max(8, window.innerWidth - rect.right)
    setMenuPos(
      spaceBelow < menuEstimatePx && spaceAbove > spaceBelow
        ? { right, bottom: window.innerHeight - rect.top + 4 }
        : { right, top: rect.bottom + 4 },
    )
  }, [open])

  const printed = token.latestPrintStatus === 'SENT'
  const showPrint =
    inQueueForPrint(token.status) && !printed && token.latestPrintStatus !== 'PENDING'
  const printing = token.latestPrintStatus === 'PENDING'

  return (
    <div
      ref={rootRef}
      className={[
        'relative z-30 grid w-[5.5rem] shrink-0 grid-cols-2 items-center justify-items-center',
        className,
      ]
        .filter(Boolean)
        .join(' ')}
    >
      <div className="flex justify-center">
        {printing ? (
          <BrandLoader className="size-9" semanticLabel={t('boardPrinterBusy')} />
        ) : showPrint ? (
          <IconButton
            label={t('boardPrintNeeded')}
            icon={PrinterIcon}
            disabled={printerBusy}
            disabledReason={printerBusy ? t('boardPrinterBusy') : undefined}
            onClick={() => onPrint(token)}
            tone="danger"
          />
        ) : null}
      </div>
      <div className="flex justify-center">
        <IconButton
          label={t('boardRowMore')}
          icon={MenuIcon}
          onClick={() => setOpen((value) => !value)}
          aria-expanded={open}
        />
      </div>
      {open && menuPos ? (
        <div
          role="menu"
          style={menuPos}
          className="fixed z-[100] min-w-[11rem] rounded-xl border border-brand-navy/10 bg-white py-1 shadow-lg dark:border-white/10 dark:bg-brand-navy-raised"
        >
          <button
            type="button"
            role="menuitem"
            className="block w-full px-4 py-2.5 text-left text-sm hover:bg-brand-mist dark:hover:bg-white/5"
            onClick={() => {
              setOpen(false)
              onEditPatient(token)
            }}
          >
            {t('boardRowEditPatient')}
          </button>
          {inQueueForPrint(token.status) ? (
            <button
              type="button"
              role="menuitem"
              className="block w-full px-4 py-2.5 text-left text-sm hover:bg-brand-mist dark:hover:bg-white/5"
              onClick={() => {
                setOpen(false)
                onReprint(token)
              }}
            >
              {t('boardReprint')}
            </button>
          ) : null}
          {activeToken(token.status) ? (
            <button
              type="button"
              role="menuitem"
              className="block w-full px-4 py-2.5 text-left text-sm text-brand-coral-action hover:bg-brand-mist dark:hover:bg-white/5"
              onClick={() => {
                setOpen(false)
                onCancel(token)
              }}
            >
              {t('boardRowCancelToken')}
            </button>
          ) : null}
        </div>
      ) : null}
    </div>
  )
}
