/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

export type StopTime12 = {
  hour: number
  minute: number
  period: 'AM' | 'PM'
}

const boundaryPattern = /^([01]\d|2[0-3]):([0-5]\d)$/

/** Parses API `HH:mm` (24h) into 12-hour parts for the form. */
export function dayBoundaryTo12Hour(dayBoundary: string): StopTime12 {
  const match = boundaryPattern.exec(dayBoundary.trim())
  if (!match) return { hour: 3, minute: 0, period: 'AM' }
  const hour24 = Number(match[1])
  const minute = Number(match[2])
  const period: 'AM' | 'PM' = hour24 >= 12 ? 'PM' : 'AM'
  const hour12 = hour24 % 12 || 12
  return { hour: hour12, minute, period }
}

/** Converts 12-hour form values to API `HH:mm`. */
export function toDayBoundary24(hour12: number, minute: number, period: 'AM' | 'PM'): string {
  let hour24 = hour12 % 12
  if (period === 'PM') hour24 += 12
  return `${String(hour24).padStart(2, '0')}:${String(minute).padStart(2, '0')}`
}

export function isValidDayBoundary(value: string): boolean {
  return boundaryPattern.test(value.trim())
}

/** User-visible stop time with 12-hour clock and AM/PM. */
export function formatDayBoundaryForDisplay(dayBoundary: string): string {
  const { hour, minute, period } = dayBoundaryTo12Hour(dayBoundary)
  return `${hour}:${String(minute).padStart(2, '0')} ${period}`
}
