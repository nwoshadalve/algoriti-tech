/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { MessageKey } from '@/core/i18n/messages/types'

export function usersErrorKey(error: unknown): MessageKey {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'forbidden':
        return 'usersErrorForbidden'
      case 'password_change_forbidden':
        return 'usersErrorPasswordForbidden'
      case 'username_taken':
        return 'usersErrorUsernameTaken'
      case 'email_taken':
        return 'errorEmailTaken'
      case 'cannot_disable_self':
        return 'usersErrorSelf'
      case 'last_admin':
        return 'usersErrorLastAdmin'
      case 'cannot_disable_initial_admin':
        return 'usersErrorInitialAdmin'
      case 'scope_invalid':
        return 'usersErrorScopeInvalid'
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
      case 'first_name_missing':
        return 'errorFirstNameRequired'
      case 'name_too_long':
        return 'errorFirstNameTooLong'
      case 'phone_invalid':
        return 'errorPhoneInvalid'
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
