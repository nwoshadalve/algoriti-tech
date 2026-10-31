/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Display canonical queue serials with Bengali digits when locale is bn. */
export function formatQueueSerial(value: number, locale: string): string {
  const text = String(value)
  if (!locale.startsWith('bn')) return text
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯']
  return text.replace(/\d/g, (d) => bnDigits[Number(d)] ?? d)
}
