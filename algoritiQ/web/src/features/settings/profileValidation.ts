/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ProfileInput } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const PHONE_PATTERN = /^[0-9+()\-. ]+$/
const MAX_NAME = 64

export type ProfileErrors = Partial<Record<keyof ProfileInput, MessageKey>>

/** The same rules the tablet applies; checked first so most mistakes need no round trip. */
export function validateProfile(fields: ProfileInput): ProfileErrors {
  const errors: ProfileErrors = {}
  const first = fields.firstName.trim()
  const last = fields.lastName.trim()
  const email = fields.email.trim()
  const phone = fields.phone.trim()

  if (!first) errors.firstName = 'errorFirstNameRequired'
  else if (first.length > MAX_NAME) errors.firstName = 'errorFirstNameTooLong'

  if (!last) errors.lastName = 'errorLastNameRequired'
  else if (last.length > MAX_NAME) errors.lastName = 'errorLastNameTooLong'

  if (!email) errors.email = 'errorEmailRequired'
  else if (!EMAIL_PATTERN.test(email)) errors.email = 'errorEmailInvalid'

  if (phone && (phone.length > 32 || !PHONE_PATTERN.test(phone))) {
    errors.phone = 'errorPhoneInvalid'
  }
  return errors
}
