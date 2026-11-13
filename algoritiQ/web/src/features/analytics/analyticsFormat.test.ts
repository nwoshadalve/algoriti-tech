/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import {
  addDays,
  change,
  compact,
  periodTitle,
  pointLabel,
  pointTitle,
  shiftPeriod,
  ticks,
} from '@/features/analytics/analyticsFormat'

describe('moving between periods', () => {
  it('should add days across a month and a year end', () => {
    expect(addDays('2026-11-30', 1)).toBe('2026-12-01')
    expect(addDays('2026-12-31', 1)).toBe('2027-01-01')
    expect(addDays('2026-03-01', -1)).toBe('2026-02-28')
  })

  it('should ask for the day before the period, or the day after it', () => {
    const week = { fromDate: '2026-11-02', toDate: '2026-11-08' }

    expect(shiftPeriod(week, -1)).toBe('2026-11-01')
    expect(shiftPeriod(week, 1)).toBe('2026-11-09')
  })
})

describe('names of points and periods', () => {
  it('should label each kind of point for an axis', () => {
    expect(pointLabel('en', 'day', '2026-11-07T14')).toBe('2 PM')
    expect(pointLabel('en', 'week', '2026-11-07')).toBe('Sat')
    expect(pointLabel('en', 'month', '2026-11-07')).toBe('7')
    expect(pointLabel('en', 'year', '2026-03')).toBe('Mar')
    expect(pointLabel('en', 'all', '2026')).toBe('2026')
  })

  it('should name a point in full for a tooltip', () => {
    expect(pointTitle('en', 'day', '2026-11-07T09')).toBe('9 AM – 10 AM')
    expect(pointTitle('en', 'year', '2026-03')).toBe('March 2026')
  })

  it('should title the period shown', () => {
    expect(periodTitle('en', { period: 'day', fromDate: '2026-11-07', toDate: '2026-11-07' })).toBe(
      'Saturday, November 7, 2026',
    )
    expect(periodTitle('en', { period: 'week', fromDate: '2026-11-02', toDate: '2026-11-08' })).toBe(
      'Nov 2 – Nov 8, 2026',
    )
    expect(periodTitle('en', { period: 'month', fromDate: '2026-11-01', toDate: '2026-11-30' })).toBe(
      'November 2026',
    )
    expect(periodTitle('en', { period: 'year', fromDate: '2026-01-01', toDate: '2026-12-31' })).toBe('2026')
  })
})

describe('figures', () => {
  it('should compare with the period before as a fraction', () => {
    expect(change(112, 100)).toBeCloseTo(0.12)
    expect(change(80, 100)).toBeCloseTo(-0.2)
  })

  it('should have nothing to compare with when the period before had nothing', () => {
    expect(change(5, 0)).toBeNull()
    expect(change(5, null)).toBeNull()
    expect(change(5, undefined)).toBeNull()
  })

  it('should shorten large numbers for a narrow space', () => {
    expect(compact('en', 1284)).toBe('1.3K')
    expect(compact('en', 12_947)).toBe('12.9K')
    expect(compact('en', 950)).toBe('950')
  })
})

describe('axis ticks', () => {
  it('should fall on round whole numbers that reach the biggest value', () => {
    expect(ticks(27)).toEqual([0, 10, 20, 30, 40])
    expect(ticks(8)).toEqual([0, 2, 4, 6, 8])
    expect(ticks(12_780)).toEqual([0, 5000, 10000, 15000, 20000])
    expect(ticks(3)).toEqual([0, 1, 2, 3, 4])
  })

  it('should still draw an axis when there is nothing to show', () => {
    expect(ticks(0)).toEqual([0, 1, 2, 3, 4])
  })

  it('should always reach at least the biggest value', () => {
    for (const max of [1, 4, 9, 27, 99, 101, 640, 12_780, 400_000]) {
      const axis = ticks(max)
      expect(axis[axis.length - 1]).toBeGreaterThanOrEqual(max)
    }
  })
})
