/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

describe('formatQueueSerial', () => {
  it('should keep Western digits in English', () => {
    expect(formatQueueSerial(1001, 'en')).toBe('1001')
  })

  it('should use Bengali digits in bn', () => {
    expect(formatQueueSerial(1001, 'bn')).toBe('১০০১')
  })
})
