/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Analytics, AnalyticsPeriod } from '@/core/api/analytics'

/** A day given as `YYYY-MM-DD`, read as that calendar day (no time zone). */
export function parseDay(date: string): Date {
  const [y, m, d] = date.split('-').map(Number)
  return new Date(Date.UTC(y!, (m ?? 1) - 1, d ?? 1))
}

export function dayKey(date: Date): string {
  return date.toISOString().slice(0, 10)
}

export function addDays(date: string, days: number): string {
  const d = parseDay(date)
  d.setUTCDate(d.getUTCDate() + days)
  return dayKey(d)
}

/** The day to ask for to see the period before (`step` -1) or after (`step` 1) this one. */
export function shiftPeriod(analytics: Pick<Analytics, 'fromDate' | 'toDate'>, step: -1 | 1): string {
  return step < 0 ? addDays(analytics.fromDate, -1) : addDays(analytics.toDate, 1)
}

const dateTime = (locale: string, options: Intl.DateTimeFormatOptions, date: Date) =>
  new Intl.DateTimeFormat(locale, { timeZone: 'UTC', ...options }).format(date)

/** The label of one point of the series, short enough for an axis. */
export function pointLabel(locale: string, period: AnalyticsPeriod, key: string): string {
  switch (period) {
    case 'day': {
      const hour = Number(key.slice(11, 13))
      return dateTime(locale, { hour: 'numeric' }, new Date(Date.UTC(2000, 0, 1, hour)))
    }
    case 'week':
      return dateTime(locale, { weekday: 'short' }, parseDay(key))
    case 'month':
      return dateTime(locale, { day: 'numeric' }, parseDay(key))
    case 'year':
      return dateTime(locale, { month: 'short' }, parseDay(`${key}-01`))
    case 'all':
      return key
  }
}

/** The full name of one point, for a tooltip or a table row. */
export function pointTitle(locale: string, period: AnalyticsPeriod, key: string): string {
  switch (period) {
    case 'day': {
      const hour = Number(key.slice(11, 13))
      const from = dateTime(locale, { hour: 'numeric' }, new Date(Date.UTC(2000, 0, 1, hour)))
      const to = dateTime(locale, { hour: 'numeric' }, new Date(Date.UTC(2000, 0, 1, hour + 1)))
      return `${from} – ${to}`
    }
    case 'week':
    case 'month':
      return dateTime(locale, { weekday: 'short', day: 'numeric', month: 'short' }, parseDay(key))
    case 'year':
      return dateTime(locale, { month: 'long', year: 'numeric' }, parseDay(`${key}-01`))
    case 'all':
      return key
  }
}

/** What the period is called in the page header: the day, the week's range, the month, the year. */
export function periodTitle(locale: string, analytics: Pick<Analytics, 'period' | 'fromDate' | 'toDate'>): string {
  const from = parseDay(analytics.fromDate)
  const to = parseDay(analytics.toDate)
  switch (analytics.period) {
    case 'day':
      return dateTime(locale, { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }, from)
    case 'week': {
      const short = { day: 'numeric', month: 'short' } as const
      return `${dateTime(locale, short, from)} – ${dateTime(locale, { ...short, year: 'numeric' }, to)}`
    }
    case 'month':
      return dateTime(locale, { month: 'long', year: 'numeric' }, from)
    case 'year':
      return dateTime(locale, { year: 'numeric' }, from)
    case 'all':
      return `${dateTime(locale, { month: 'short', year: 'numeric' }, from)} – ${dateTime(locale, { month: 'short', year: 'numeric' }, to)}`
  }
}

/** 1,284 / 12.9K / 4.2M for a figure that has to fit a small space. */
export function compact(locale: string, value: number): string {
  return new Intl.NumberFormat(locale, { notation: 'compact', maximumFractionDigits: 1 }).format(value)
}

/** A change against the period before, as a fraction (0.12 is up 12%); null when there is nothing to compare. */
export function change(current: number, previous: number | null | undefined): number | null {
  if (previous == null || previous === 0) return null
  return (current - previous) / previous
}

/** A round step (1, 2, 5 or 10 times a power of ten) at least as big as `rough`. */
function niceStep(rough: number): number {
  if (rough <= 1) return 1
  const base = 10 ** Math.floor(Math.log10(rough))
  const fraction = rough / base
  const nice = fraction <= 1 ? 1 : fraction <= 2 ? 2 : fraction <= 5 ? 5 : 10
  return nice * base
}

/** Axis ticks from 0 up: `count` steps of a round size that together reach `max`. */
export function ticks(max: number, count = 4): number[] {
  const step = max <= 0 ? 1 : niceStep(max / count)
  return Array.from({ length: count + 1 }, (_, i) => step * i)
}
