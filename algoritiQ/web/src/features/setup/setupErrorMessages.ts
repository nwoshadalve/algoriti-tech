/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { MessageKey } from '@/core/i18n/messages/types'

export function setupErrorKey(error: unknown): MessageKey {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'claim_code_invalid':
        return error.attemptsLeft != null
          ? 'errorClaimCodeInvalidWithAttempts'
          : 'errorClaimCodeInvalid'
      case 'claim_code_expired':
        return 'errorClaimCodeExpired'
      case 'claim_code_locked':
        return 'errorClaimCodeLocked'
      case 'admin_already_registered':
        return 'errorAdminAlreadyRegistered'
      case 'username_invalid':
        return 'errorUsernameInvalidApi'
      case 'email_invalid':
        return 'errorEmailInvalidApi'
      case 'password_too_short':
        return 'errorPasswordTooShortApi'
      case 'password_too_long':
        return 'errorPasswordTooLongApi'
      case 'password_contains_username':
        return 'errorPasswordContainsUsernameApi'
      case 'invalid_request':
        return 'errorInvalidRequest'
      default:
        return 'errorGeneric'
    }
  }

  if (error instanceof TypeError) {
    return 'errorNetwork'
  }

  return 'errorGeneric'
}

export function isClaimCodeApiError(error: unknown): boolean {
  if (!(error instanceof ApiError)) return false
  return (
    error.code === 'claim_code_invalid' ||
    error.code === 'claim_code_expired' ||
    error.code === 'claim_code_locked'
  )
}

export function setupErrorParams(error: unknown): Record<string, string | number> | undefined {
  if (error instanceof ApiError && error.code === 'claim_code_invalid' && error.attemptsLeft != null) {
    return { count: error.attemptsLeft }
  }
  return undefined
}
