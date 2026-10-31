/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it } from 'vitest'
import {
  readSetupRegisteredCache,
  writeSetupRegisteredCache,
} from '@/features/auth/setupRegisteredCache'

describe('setup registered cache', () => {
  afterEach(() => {
    sessionStorage.clear()
  })

  it('should remember that an admin exists for this tab', () => {
    expect(readSetupRegisteredCache()).toBe(false)
    writeSetupRegisteredCache(true)
    expect(readSetupRegisteredCache()).toBe(true)
    writeSetupRegisteredCache(false)
    expect(readSetupRegisteredCache()).toBe(false)
  })
})
