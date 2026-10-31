/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it } from 'vitest'
import {
  clearLicenseCache,
  effectiveLicenseType,
  readLicenseCache,
  writeLicenseCache,
} from '@/core/clinic/clinicLicenseCache'

describe('clinic license cache', () => {
  afterEach(() => {
    clearLicenseCache()
  })

  it('should remember the license type for navigation', () => {
    writeLicenseCache('doctor')
    expect(readLicenseCache()).toBe('doctor')
    expect(effectiveLicenseType(undefined)).toBe('doctor')
  })
})
