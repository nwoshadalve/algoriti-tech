/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { formatDigits } from '@/features/queue/formatQueueSerial'

describe('formatDigits', () => {
  it('should write the digits of a patient ID in Bengali for a Bengali page', () => {
    expect(formatDigits('7761', 'bn')).toBe('৭৭৬১')
    expect(formatDigits('P-000001', 'bn-BD')).toBe('P-০০০০০১')
  })

  it('should leave the ID as it is for an English page', () => {
    expect(formatDigits('7761', 'en')).toBe('7761')
    expect(formatDigits('P-000001', 'en-US')).toBe('P-000001')
  })
})
