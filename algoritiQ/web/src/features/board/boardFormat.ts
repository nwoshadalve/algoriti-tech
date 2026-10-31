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
