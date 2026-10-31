/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

const MIN_LENGTH = 8
const MAX_LENGTH = 128

export type PasswordFields = { current: string; next: string; confirm: string }
export type PasswordErrors = Partial<Record<keyof PasswordFields, MessageKey>>

/** The tablet's rules for a password, checked first so most mistakes need no round trip. */
export function validatePasswordChange(fields: PasswordFields, username: string): PasswordErrors {
  const errors: PasswordErrors = {}
  if (!fields.current) errors.current = 'errorCurrentPasswordRequired'

  if (!fields.next) errors.next = 'errorPasswordRequired'
  else if (fields.next.length < MIN_LENGTH) errors.next = 'errorPasswordTooShort'
  else if (fields.next.length > MAX_LENGTH) errors.next = 'errorPasswordTooLong'
  else if (fields.next.toLowerCase().includes(username.toLowerCase())) {
    errors.next = 'errorPasswordContainsUsername'
  } else if (fields.next === fields.current) errors.next = 'errorPasswordUnchanged'

  if (!fields.confirm) errors.confirm = 'errorConfirmPasswordRequired'
  else if (fields.confirm !== fields.next) errors.confirm = 'errorConfirmPasswordMismatch'
  return errors
}
