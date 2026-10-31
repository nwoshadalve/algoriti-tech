/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ChamberInput } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

const MAX_NAME = 120
const MAX_FIELD = 200
const MAX_PHONE = 32
const PHONE_PATTERN = /^[0-9+()\-. ]+$/

export type ChamberErrors = Partial<Record<keyof ChamberInput, MessageKey>>

/** The tablet's rules (all three fields are required), checked first so most mistakes need no round trip. */
export function validateChamber(fields: ChamberInput): ChamberErrors {
  const errors: ChamberErrors = {}
  const name = fields.name.trim()
  const location = fields.location.trim()
  const phone = fields.phone.trim()

  if (!name) errors.name = 'chamberErrorName'
  else if (name.length > MAX_NAME) errors.name = 'doctorErrorTooLong'

  if (!location) errors.location = 'chamberErrorAddress'
  else if (location.length > MAX_FIELD) errors.location = 'doctorErrorTooLong'

  if (!phone) errors.phone = 'chamberErrorPhone'
  else if (phone.length > MAX_PHONE || !PHONE_PATTERN.test(phone)) errors.phone = 'errorPhoneInvalid'
  return errors
}
