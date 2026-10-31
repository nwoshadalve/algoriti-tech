/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import {
  markQueueConfigurationSavedLocally,
  shouldShowQueueConfigurationLiveToast,
} from '@/features/queue/queueLocalChange'

describe('queueLocalChange', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it('should suppress live toast right after a local save', () => {
    expect(shouldShowQueueConfigurationLiveToast()).toBe(true)
    markQueueConfigurationSavedLocally(3_000)
    expect(shouldShowQueueConfigurationLiveToast()).toBe(false)
    vi.advanceTimersByTime(3_001)
    expect(shouldShowQueueConfigurationLiveToast()).toBe(true)
  })
})
