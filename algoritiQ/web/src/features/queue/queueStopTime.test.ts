/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { dayBoundaryTo12Hour, formatDayBoundaryForDisplay, toDayBoundary24 } from '@/features/queue/queueStopTime'

describe('queueStopTime', () => {
  it('should round-trip 03:00 as 3:00 AM', () => {
    const parts = dayBoundaryTo12Hour('03:00')
    expect(parts).toEqual({ hour: 3, minute: 0, period: 'AM' })
    expect(toDayBoundary24(parts.hour, parts.minute, parts.period)).toBe('03:00')
  })

  it('should convert 2:30 PM to 14:30', () => {
    expect(toDayBoundary24(2, 30, 'PM')).toBe('14:30')
    expect(dayBoundaryTo12Hour('14:30')).toEqual({ hour: 2, minute: 30, period: 'PM' })
  })

  it('should format display time with AM or PM', () => {
    expect(formatDayBoundaryForDisplay('03:00')).toBe('3:00 AM')
    expect(formatDayBoundaryForDisplay('14:30')).toBe('2:30 PM')
  })
})
