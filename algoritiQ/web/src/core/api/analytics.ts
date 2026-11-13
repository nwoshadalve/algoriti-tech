/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'

export type AnalyticsPeriod = 'day' | 'week' | 'month' | 'year' | 'all'

/** The figures of one stretch of time: a whole period, or one point of it. */
export type AnalyticsTotals = {
  sessions: number
  tokens: number
  /** Seen by the doctor. */
  entered: number
  /** Called but did not come in. */
  skipped: number
  cancelled: number
  /** Still waiting, or called and never resolved, when the session ended. */
  notSeen: number
  /** Fees in BDT; cancelled tokens left out. */
  feeBdt: number
  newPatients: number
  /** Different patients who had a token. */
  patients: number
  averageWaitSeconds: number | null
  longestWaitSeconds: number | null
  averageSessionMinutes: number | null
}

/** One point of the series: `YYYY-MM-DDTHH`, `YYYY-MM-DD`, `YYYY-MM` or `YYYY` in clinic time. */
export type AnalyticsPoint = AnalyticsTotals & { key: string }

export type AnalyticsQueueStat = AnalyticsTotals & {
  queueTypeId: string
  englishName: string
  bengaliName: string
}

export type AnalyticsChamberStat = AnalyticsTotals & { chamberId: string; name: string }

/** Tokens and fees of one hour of the day, or of one weekday. */
export type AnalyticsSlot = { tokens: number; feeBdt: number }

export type Analytics = {
  period: AnalyticsPeriod
  granularity: 'hour' | 'day' | 'month' | 'year'
  timeZone: string
  /** First and last day of the period, `YYYY-MM-DD` in clinic time. */
  fromDate: string
  toDate: string
  previousFromDate: string | null
  previousToDate: string | null
  totals: AnalyticsTotals
  /** The same period one step back; null for all time. */
  previous: AnalyticsTotals | null
  series: AnalyticsPoint[]
  byQueue: AnalyticsQueueStat[]
  byChamber: AnalyticsChamberStat[]
  /** 24 slots, hour 0 to 23. */
  byHour: AnalyticsSlot[]
  /** 7 slots, Monday first. */
  byWeekday: AnalyticsSlot[]
}

export type AnalyticsQuery = {
  period: AnalyticsPeriod
  /** A day inside the period, `YYYY-MM-DD`; today when empty. */
  date?: string
  chamberId?: string
}

/** The figures of one period for the admin (tablet: `GET /analytics`). */
export function getAnalytics(token: string, query: AnalyticsQuery): Promise<Analytics> {
  const params = new URLSearchParams({ period: query.period })
  if (query.date) params.set('date', query.date)
  if (query.chamberId) params.set('chamberId', query.chamberId)
  return apiFetch<Analytics>(`/analytics?${params.toString()}`, { headers: bearer(token) })
}
