/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useRef, useState } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { AlertCircleIcon, CheckCircleIcon, CloseIcon } from '@/core/ui/icons'
import { Tooltip } from '@/core/ui/Tooltip'
import type { ToastTone } from '@/core/toast/toastContext'

export type ToastItem = {
  id: number
  tone: ToastTone
  message: string
  /** Changes when the same toast is raised again, to restart its timer. */
  stamp: number
}

const LIFETIME_MS: Record<ToastTone, number> = { success: 4500, error: 8000 }

const tones = {
  success: {
    accent: 'bg-emerald-500',
    icon: 'text-emerald-600 dark:text-emerald-400',
    Icon: CheckCircleIcon,
  },
  error: {
    accent: 'bg-brand-coral',
    icon: 'text-brand-coral-action dark:text-brand-coral',
    Icon: AlertCircleIcon,
  },
} as const

type ToasterProps = {
  toasts: ToastItem[]
  onDismiss: (id: number) => void
}

/** The stack of toasts: bottom right on wide screens, full width at the bottom on phones. */
export function Toaster({ toasts, onDismiss }: ToasterProps) {
  const { t } = useLocale()

  return (
    <div
      aria-live="polite"
      aria-label={t('toastRegionLabel')}
      className="pointer-events-none fixed inset-x-0 bottom-0 z-[80] flex flex-col gap-2 p-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] sm:inset-x-auto sm:right-0 sm:w-[26rem] sm:p-5"
    >
      {toasts.map((toast) => (
        <ToastCard key={toast.id} toast={toast} onDismiss={onDismiss} />
      ))}
    </div>
  )
}

function ToastCard({ toast, onDismiss }: { toast: ToastItem; onDismiss: (id: number) => void }) {
  const { t } = useLocale()
  const lifetime = LIFETIME_MS[toast.tone]
  const timer = useRef<number | undefined>(undefined)
  const left = useRef(lifetime)
  const startedAt = useRef(0)
  const running = useRef(false)
  const [paused, setPaused] = useState(false)

  function start() {
    if (running.current) return
    running.current = true
    startedAt.current = Date.now()
    timer.current = window.setTimeout(() => onDismiss(toast.id), left.current)
  }

  function stop() {
    if (!running.current) return
    running.current = false
    window.clearTimeout(timer.current)
    left.current = Math.max(0, left.current - (Date.now() - startedAt.current))
  }

  // A fresh `stamp` (same message raised again) starts the countdown over.
  useEffect(() => {
    left.current = lifetime
    running.current = false
    start()
    return () => {
      running.current = false
      window.clearTimeout(timer.current)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps -- restart on `stamp` only
  }, [toast.stamp])

  function hold() {
    stop()
    setPaused(true)
  }

  function release() {
    setPaused(false)
    start()
  }

  const { accent, icon, Icon } = tones[toast.tone]

  return (
    <div
      role={toast.tone === 'error' ? 'alert' : undefined}
      data-tone={toast.tone}
      onMouseEnter={hold}
      onMouseLeave={release}
      onFocus={hold}
      onBlur={release}
      className="toast-enter pointer-events-auto relative overflow-hidden rounded-xl border border-brand-navy/10 bg-white text-brand-navy shadow-lg shadow-brand-navy/10 dark:border-white/10 dark:bg-brand-navy-raised dark:text-white dark:shadow-black/30"
    >
      <div className="flex items-start gap-3 py-3 pr-2 pl-4">
        <Icon className={`mt-0.5 shrink-0 ${icon}`} />
        <p className="min-w-0 flex-1 py-0.5 text-sm leading-relaxed">{toast.message}</p>
        <Tooltip label={t('toastClose')}>
          <button
            type="button"
            aria-label={t('toastClose')}
            onClick={() => onDismiss(toast.id)}
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg text-brand-navy/60 transition-colors hover:bg-brand-navy/5 hover:text-brand-navy focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:text-white/60 dark:hover:bg-white/10 dark:hover:text-white"
          >
            <CloseIcon width={18} height={18} />
          </button>
        </Tooltip>
      </div>
      <span
        key={toast.stamp}
        aria-hidden="true"
        className={`toast-countdown absolute bottom-0 left-0 h-1 w-full origin-left ${accent}`}
        style={{
          animationDuration: `${lifetime}ms`,
          animationPlayState: paused ? 'paused' : 'running',
        }}
      />
    </div>
  )
}
