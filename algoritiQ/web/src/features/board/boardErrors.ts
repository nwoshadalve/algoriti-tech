/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { MessageKey } from '@/core/i18n/messages/types'

/** Maps queue-board API refusals to user-facing message keys. */
export function boardErrorKey(error: unknown): MessageKey {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'forbidden':
        return 'boardErrorForbidden'
      case 'chamber_not_found':
        return 'boardErrorChamberNotFound'
      case 'session_closed':
        return 'boardErrorSessionClosed'
      case 'duplicate_phone_needs_confirm':
        return 'boardErrorDuplicatePhone'
      case 'patient_has_active_token':
        return 'boardErrorActiveToken'
      case 'range_exhausted':
        return 'boardErrorRangeExhausted'
      case 'no_waiting_token':
        return 'boardErrorNoWaiting'
      case 'no_called_token':
        return 'boardErrorNoCalled'
      case 'unresolved_called_token':
        return 'boardErrorUnresolvedCall'
      case 'queue_board_validation':
      case 'validation':
        return 'boardErrorValidation'
      default:
        return 'errorGeneric'
    }
  }
  return error instanceof TypeError ? 'errorNetwork' : 'errorGeneric'
}
