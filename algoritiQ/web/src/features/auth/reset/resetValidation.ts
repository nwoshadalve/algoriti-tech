/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

export type NewPasswordErrors = {
  newPassword?: MessageKey
  confirmPassword?: MessageKey
}

/** The same rules as registering; the tablet checks them again. */
export function validateNewPassword(
  username: string,
  newPassword: string,
  confirmPassword: string,
): NewPasswordErrors {
  const errors: NewPasswordErrors = {}
  const name = username.trim().toLowerCase()

  if (!newPassword) {
    errors.newPassword = 'errorPasswordRequired'
  } else if (newPassword.length < 8) {
    errors.newPassword = 'errorPasswordTooShort'
  } else if (newPassword.length > 128) {
    errors.newPassword = 'errorPasswordTooLong'
  } else if (name && newPassword.toLowerCase().includes(name)) {
    errors.newPassword = 'errorPasswordContainsUsername'
  }

  if (!confirmPassword) {
    errors.confirmPassword = 'errorConfirmPasswordRequired'
  } else if (confirmPassword !== newPassword) {
    errors.confirmPassword = 'errorConfirmPasswordMismatch'
  }

  return errors
}
