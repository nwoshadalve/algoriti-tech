/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { createContext, useContext } from 'react'

export type ToastTone = 'success' | 'error'

export type ToastApi = {
  /** Something worked: saved, changed, signed out. Goes away by itself. */
  success: (message: string) => void
  /** Something failed. Stays a little longer than a success. */
  error: (message: string) => void
}

/** The most toasts on screen at once; a sixth pushes the oldest off. */
export const MAX_TOASTS = 5

export const ToastContext = createContext<ToastApi | null>(null)

export function useToast(): ToastApi {
  const ctx = useContext(ToastContext)
  if (!ctx) {
    throw new Error('useToast must be used within ToastProvider')
  }
  return ctx
}
