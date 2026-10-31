/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import type { QueueTypeConfig } from '@/core/api/types'
import { validateQueueTypeFields } from '@/features/queue/queueValidation'

const sibling: QueueTypeConfig = {
  id: 'regular',
  englishName: 'Regular',
  bengaliName: 'সাধারণ',
  startNumber: 1001,
  endNumber: 1099,
  displayOrder: 1,
  enabled: true,
}

describe('validateQueueTypeFields', () => {
  it('should require names and a valid range', () => {
    const errors = validateQueueTypeFields(
      { englishName: '', bengaliName: '', startNumber: '0', endNumber: '5' },
      [sibling],
      undefined,
    )
    expect(errors.englishName).toBe('queueErrorEnglishName')
    expect(errors.startNumber).toBe('queueErrorStart')
  })

  it('should reject overlapping enabled ranges', () => {
    const errors = validateQueueTypeFields(
      {
        englishName: 'Extra',
        bengaliName: 'অতিরিক্ত',
        startNumber: '1050',
        endNumber: '1100',
      },
      [sibling],
      undefined,
    )
    expect(errors.startNumber).toBe('queueErrorOverlap')
  })
})
