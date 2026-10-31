/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { MessageKey } from '@/core/i18n/messages/types'

/** Maps queue API refusals to user-facing message keys. */
export function queueErrorKey(error: unknown): MessageKey {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'queue_validation_failed':
        return 'queueErrorValidation'
      case 'queue_session_open':
        return 'queueErrorSessionOpen'
      case 'queue_chamber_inherits_defaults':
        return 'queueErrorInheritDefaults'
      case 'forbidden':
        return 'queueErrorForbidden'
      default:
        return 'errorGeneric'
    }
  }
  return error instanceof TypeError ? 'errorNetwork' : 'errorGeneric'
}
