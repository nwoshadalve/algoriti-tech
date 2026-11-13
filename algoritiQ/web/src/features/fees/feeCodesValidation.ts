/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** The same limits the tablet enforces. */
export const FEE_CODES_MAX = 50
export const FEE_CODE_MAX_LENGTH = 16
export const FEE_AMOUNT_MAX = 9_999_999

export type FeeCodeRow = {
  /** Local key for the list; not sent. */
  key: string
  /** The tablet's id of a saved code; empty for a new one. */
  id: string
  code: string
  /** What is typed: kept as text until it is checked. */
  amount: string
}

export type FeeCodeRowError = 'codeRequired' | 'codeDuplicate' | 'amountInvalid'

/** A whole number from 1 to the limit, or null. */
export function parseFeeAmount(text: string): number | null {
  const trimmed = text.trim()
  if (!/^\d+$/.test(trimmed)) return null
  const value = Number(trimmed)
  return value >= 1 && value <= FEE_AMOUNT_MAX ? value : null
}

/** What is wrong with each row (by key); a valid row is absent. Codes are compared without regard to case. */
export function validateFeeRows(rows: FeeCodeRow[]): Map<string, FeeCodeRowError> {
  const errors = new Map<string, FeeCodeRowError>()
  const seen = new Set<string>()
  for (const row of rows) {
    const code = row.code.trim()
    if (!code) {
      errors.set(row.key, 'codeRequired')
    } else if (seen.has(code.toLowerCase())) {
      errors.set(row.key, 'codeDuplicate')
    } else if (parseFeeAmount(row.amount) === null) {
      errors.set(row.key, 'amountInvalid')
    }
    if (code) seen.add(code.toLowerCase())
  }
  return errors
}
