/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { DoctorInput } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

const MAX_NAME = 120
const MAX_FIELD = 200
const MAX_DEGREES = 12
const MAX_DEGREE = 60

export type DoctorErrors = Partial<Record<'name' | 'degrees' | 'designation' | 'workplace' | 'registrationNumber' | 'specialty', MessageKey>>

/** Degrees are typed as one line, separated by commas. */
export function parseDegrees(text: string): string[] {
  return text
    .split(',')
    .map((degree) => degree.trim())
    .filter(Boolean)
}

/** The tablet's rules, checked first so most mistakes need no round trip. */
export function validateDoctor(fields: Omit<DoctorInput, 'degrees'> & { degrees: string }): DoctorErrors {
  const errors: DoctorErrors = {}
  const name = fields.name.trim()
  if (!name) errors.name = 'doctorErrorName'
  else if (name.length > MAX_NAME) errors.name = 'doctorErrorTooLong'

  const degrees = parseDegrees(fields.degrees)
  if (degrees.length > MAX_DEGREES) errors.degrees = 'doctorErrorDegrees'
  else if (degrees.some((degree) => degree.length > MAX_DEGREE)) errors.degrees = 'doctorErrorTooLong'

  for (const key of ['designation', 'workplace', 'registrationNumber', 'specialty'] as const) {
    if (fields[key].trim().length > MAX_FIELD) errors[key] = 'doctorErrorTooLong'
  }
  return errors
}
