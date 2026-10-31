/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

export const PIN_LENGTH = 6

/** The tablet's rules for a PIN: six digits, and not an obvious guess. */
export function validatePin(pin: string): MessageKey | null {
  if (!pin) return 'errorPinRequired'
  if (pin.length !== PIN_LENGTH || !/^[0-9]+$/.test(pin)) return 'errorPinFormat'
  const digits = [...pin].map(Number)
  const steps = new Set(digits.slice(1).map((digit, i) => digit - digits[i]))
  const repeated = steps.size === 1 && steps.has(0)
  const run = steps.size === 1 && (steps.has(1) || steps.has(-1))
  return repeated || run ? 'errorPinWeak' : null
}
