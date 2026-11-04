/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'
import type { TokenStatus } from '@/core/api/types'

export function queueDisplayName(
  locale: string,
  englishName: string,
  bengaliName: string,
): string {
  if (locale.startsWith('bn') && bengaliName.trim()) return bengaliName
  return englishName
}

export const tokenStatusLabelKey: Record<TokenStatus, MessageKey> = {
  WAITING: 'boardTokenWaiting',
  CALLED: 'boardTokenCalled',
  ENTERED: 'boardTokenEntered',
  SKIPPED: 'boardTokenSkipped',
  CANCELLED: 'boardTokenCancelled',
}

/** Minutes between two ISO timestamps for the session table. */
export function waitingMinutesSince(issuedAt: string, nowMs: number): number {
  const start = Date.parse(issuedAt)
  if (!Number.isFinite(start)) return 0
  return Math.max(0, Math.floor((nowMs - start) / 60_000))
}

/** Elapsed wait in ms from issue until first call or terminal status, then frozen. */
export function waitingElapsedMs(
  issuedAt: string,
  nowMs: number,
  firstCalledAt?: string | null,
  enteredAt?: string | null,
): number {
  const start = Date.parse(issuedAt)
  if (!Number.isFinite(start)) return 0
  const endRaw = firstCalledAt ?? enteredAt
  const end = endRaw != null && endRaw !== '' ? Date.parse(endRaw) : nowMs
  if (!Number.isFinite(end)) return 0
  return Math.max(0, end - start)
}

/** Live wait display: mm:ss, or h:mm:ss from one hour. */
export function formatWaitElapsed(elapsedMs: number, locale: string): string {
  const totalSeconds = Math.floor(elapsedMs / 1000)
  const hours = Math.floor(totalSeconds / 3600)
  const minutes = Math.floor((totalSeconds % 3600) / 60)
  const seconds = totalSeconds % 60
  const pad = (n: number) => String(n).padStart(2, '0')
  const core =
    hours > 0 ? `${hours}:${pad(minutes)}:${pad(seconds)}` : `${pad(minutes)}:${pad(seconds)}`
  if (!locale.startsWith('bn')) return core
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯']
  return core.replace(/\d/g, (d) => bnDigits[Number(d)] ?? d)
}

export function formatDurationMinutes(minutes: number, locale: string): string {
  if (minutes < 1) {
    return locale.startsWith('bn') ? '১ মি.' : '1 min'
  }
  const text = String(minutes)
  if (!locale.startsWith('bn')) return `${text} min`
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯']
  const localized = text.replace(/\d/g, (d) => bnDigits[Number(d)] ?? d)
  return `${localized} মি.`
}

/** Idempotent command id for board mutations. */
export function newBoardCommandId(): string {
  return crypto.randomUUID()
}

/** Parses English or Bengali digit input; null when not a whole number. */
export function parseDeskNumber(text: string): number | null {
  const ascii = text.trim().replace(/[০-৯]/g, (ch) => String(ch.charCodeAt(0) - 0x09e6 + 0x30))
  const parsed = Number.parseInt(ascii, 10)
  return Number.isFinite(parsed) ? parsed : null
}

/** Grapheme count for search minimum length (matches tablet desk). */
export function deskSearchGraphemeCount(text: string): number {
  const trimmed = text.trim()
  if (typeof Intl !== 'undefined' && 'Segmenter' in Intl) {
    return [...new Intl.Segmenter(undefined, { granularity: 'grapheme' }).segment(trimmed)].length
  }
  return trimmed.length
}
