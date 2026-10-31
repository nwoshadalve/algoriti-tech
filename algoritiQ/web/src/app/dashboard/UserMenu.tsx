/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useId, useRef, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import type { Account } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import { Avatar } from '@/core/ui/Avatar'
import { ChevronUpDownIcon, SettingsIcon, SignOutIcon } from '@/core/ui/icons'

type UserMenuProps = {
  account: Account
  onSignOut: () => void
  signingOut: boolean
  /** Called when the person goes somewhere, so a drawer can close. */
  onNavigate?: () => void
  showChangeWorkScope?: boolean
  onChangeWorkScope?: () => void
}

const rowClass =
  'flex min-h-11 w-full items-center gap-3 rounded-xl px-3 py-2 text-sm font-medium text-brand-navy/85 transition-colors hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:text-white/85 dark:hover:bg-white/10'

/**
 * The signed-in person at the bottom of the sidebar. Opens a panel above it with
 * Settings and Sign out.
 */
export function UserMenu({ account, onSignOut, signingOut, onNavigate, showChangeWorkScope, onChangeWorkScope }: UserMenuProps) {
  const { t } = useLocale()
  const navigate = useNavigate()
  const panelId = useId()
  const [open, setOpen] = useState(false)
  const root = useRef<HTMLDivElement>(null)
  const trigger = useRef<HTMLButtonElement>(null)

  useEffect(() => {
    if (!open) return
    const onPointerDown = (event: PointerEvent) => {
      if (root.current && !root.current.contains(event.target as Node)) setOpen(false)
    }
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false)
        trigger.current?.focus()
      }
    }
    document.addEventListener('pointerdown', onPointerDown)
    document.addEventListener('keydown', onKeyDown)
    return () => {
      document.removeEventListener('pointerdown', onPointerDown)
      document.removeEventListener('keydown', onKeyDown)
    }
  }, [open])

  const name = account.displayName || account.username

  return (
    <div ref={root} className="relative">
      {open ? (
        <div
          id={panelId}
          aria-label={t('userMenuLabel')}
          className="absolute right-0 bottom-full left-0 z-10 mb-2 rounded-2xl border border-brand-navy/10 bg-white p-1.5 shadow-xl dark:border-white/10 dark:bg-brand-navy"
        >
          {showChangeWorkScope ? (
            <>
              <button
                type="button"
                className={`${rowClass} text-left`}
                onClick={() => {
                  setOpen(false)
                  onChangeWorkScope?.()
                  navigate('/work')
                  onNavigate?.()
                }}
              >
                {t('navChangeWorkScope')}
              </button>
              <div className="my-1 h-px bg-brand-navy/10 dark:bg-white/10" role="separator" />
            </>
          ) : null}
          <Link
            to="/settings"
            className={rowClass}
            onClick={() => {
              setOpen(false)
              onNavigate?.()
            }}
          >
            <SettingsIcon className="shrink-0" />
            {t('navSettings')}
          </Link>
          <div className="my-1 h-px bg-brand-navy/10 dark:bg-white/10" role="separator" />
          <button
            type="button"
            className={`${rowClass} text-left`}
            disabled={signingOut}
            onClick={onSignOut}
          >
            <SignOutIcon className="shrink-0" />
            {signingOut ? t('signingOut') : t('signOut')}
          </button>
        </div>
      ) : null}

      <button
        ref={trigger}
        type="button"
        aria-haspopup="true"
        aria-expanded={open}
        aria-controls={open ? panelId : undefined}
        aria-label={t('userMenuLabel')}
        onClick={() => setOpen((value) => !value)}
        className="flex w-full items-center gap-3 rounded-xl p-2 text-left transition-colors hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:hover:bg-white/10"
      >
        <Avatar account={account} />
        <span className="min-w-0 flex-1">
          <span className="block truncate text-sm font-semibold">{name}</span>
          <span className="block truncate text-xs text-brand-navy/65 dark:text-white/65">
            {t(roleLabelKey[account.role])}
          </span>
        </span>
        <ChevronUpDownIcon className="shrink-0 text-brand-navy/50 dark:text-white/50" />
      </button>
    </div>
  )
}
