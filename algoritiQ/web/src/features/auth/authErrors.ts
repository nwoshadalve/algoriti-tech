import { ApiError } from '@/core/api/client'
import type { MessageKey } from '@/core/i18n/messages/types'

export type ErrorMessage = { key: MessageKey; params?: Record<string, string | number> }

/** The message for a failed sign-in or password reset. */
export function authError(error: unknown): ErrorMessage {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'invalid_credentials':
        return { key: 'errorInvalidCredentials' }
      case 'too_many_attempts':
        return { key: 'errorTooManyAttempts', params: { seconds: error.retryAfterSeconds ?? 30 } }
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
