/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { Locale, MessageKey } from '@/core/i18n/messages/types'
import { formatRetryWait, formatRetryWaitBn } from '@/features/auth/retryWait'

export type ErrorMessage = { key: MessageKey; params?: Record<string, string | number> }

/** The message for a failed sign-in or password reset. */
export function authError(error: unknown, locale: Locale = 'en'): ErrorMessage {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'invalid_credentials':
        return { key: 'errorInvalidCredentials' }
      case 'invalid_pin':
        return { key: 'errorInvalidPin', params: { count: error.attemptsLeft ?? 0 } }
      case 'pin_locked':
        return { key: 'errorPinLocked' }
      case 'pin_unavailable':
        return { key: 'errorPinUnavailable' }
      case 'pin_invalid':
        return { key: 'errorPinFormat' }
      case 'pin_too_easy':
        return { key: 'errorPinWeak' }
      case 'current_password_wrong':
        return { key: 'errorCurrentPasswordWrong' }
      case 'too_many_attempts': {
        const seconds = error.retryAfterSeconds ?? 20
        const wait =
          locale === 'bn' ? formatRetryWaitBn(seconds) : formatRetryWait(seconds)
        return { key: 'errorTooManyAttempts', params: { wait } }
      }
      case 'reset_refused':
        return { key: 'errorResetRefused' }
      case 'reset_token_invalid':
        return { key: 'errorResetExpired' }
      case 'password_too_short':
        return { key: 'errorPasswordTooShortApi' }
      case 'password_too_long':
        return { key: 'errorPasswordTooLongApi' }
      case 'password_contains_username':
        return { key: 'errorPasswordContainsUsernameApi' }
      case 'invalid_request':
        return { key: 'errorInvalidRequest' }
      default:
        return { key: 'errorGeneric' }
    }
  }
  return error instanceof TypeError ? { key: 'errorNetwork' } : { key: 'errorGeneric' }
}
