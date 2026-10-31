/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ApiError } from '@/core/api/client'
import type { ChamberInput } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

/** What went wrong with a chamber change, and which field (if any) it is about. */
export function chamberError(error: unknown): { key: MessageKey; field?: keyof ChamberInput } {
  if (error instanceof ApiError) {
    switch (error.code) {
      case 'chamber_name_missing':
        return { key: 'chamberErrorName', field: 'name' }
      case 'chamber_location_missing':
        return { key: 'chamberErrorAddress', field: 'location' }
      case 'chamber_phone_missing':
        return { key: 'chamberErrorPhone', field: 'phone' }
      case 'chamber_phone_invalid':
        return { key: 'errorPhoneInvalid', field: 'phone' }
      case 'chamber_too_long':
        return { key: 'doctorErrorTooLong', field: 'name' }
      case 'chamber_limit_reached':
        return { key: 'chamberErrorLimit' }
      case 'last_chamber':
        return { key: 'chamberErrorLast' }
      case 'forbidden':
        return { key: 'usersErrorForbidden' }
      default:
        return { key: 'errorGeneric' }
    }
  }
  return { key: error instanceof TypeError ? 'errorNetwork' : 'errorGeneric' }
}
