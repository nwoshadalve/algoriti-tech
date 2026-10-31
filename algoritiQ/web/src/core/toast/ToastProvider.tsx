/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useMemo, useState, type ReactNode } from 'react'
import { Toaster, type ToastItem } from '@/core/toast/Toaster'
import { MAX_TOASTS, ToastContext, type ToastApi, type ToastTone } from '@/core/toast/toastContext'

let nextId = 0

/**
 * Holds the toasts above the router, so one raised just before a page change
 * (for example "password changed" on the way to sign-in) is still shown.
 */
export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([])

  const push = useCallback((tone: ToastTone, message: string) => {
    setToasts((current) => {
      // The same message again refreshes the one on screen instead of stacking up.
      const rest = current.filter((toast) => !(toast.tone === tone && toast.message === message))
      const next = [...rest, { id: ++nextId, tone, message, stamp: Date.now() + nextId }]
      return next.slice(-MAX_TOASTS)
    })
  }, [])

  const dismiss = useCallback((id: number) => {
    setToasts((current) => current.filter((toast) => toast.id !== id))
  }, [])

  const api = useMemo<ToastApi>(
    () => ({
      success: (message) => push('success', message),
      error: (message) => push('error', message),
    }),
    [push],
  )

  return (
    <ToastContext.Provider value={api}>
      {children}
      <Toaster toasts={toasts} onDismiss={dismiss} />
    </ToastContext.Provider>
  )
}
