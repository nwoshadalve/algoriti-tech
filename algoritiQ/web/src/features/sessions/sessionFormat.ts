/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'
import type { SessionSummary, TokenStatus } from '@/core/api/types'

type Translate = (key: MessageKey, params?: Record<string, string | number>) => string

export const tokenStatuses: TokenStatus[] = ['WAITING', 'CALLED', 'SKIPPED', 'ENTERED', 'CANCELLED']

export const tokenStatusKey: Record<TokenStatus, MessageKey> = {
  WAITING: 'boardTokenWaiting',
  CALLED: 'boardTokenCalled',
  ENTERED: 'boardTokenEntered',
  SKIPPED: 'boardTokenSkipped',
  CANCELLED: 'boardTokenCancelled',
}

export function formatDay(locale: string, iso: string): string {
  return new Intl.DateTimeFormat(locale, { dateStyle: 'full' }).format(new Date(iso))
}

/** "Fri, 6 Nov 2026": short enough for a card title. */
export function formatDayShort(locale: string, iso: string): string {
  return new Intl.DateTimeFormat(locale, {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(iso))
}

/** "Today" or "Yesterday" (in the viewer's language) for the last two days, else empty. */
export function formatRelativeDay(locale: string, iso: string, nowMs: number): string {
  const startOfDay = (ms: number) => {
    const d = new Date(ms)
    return new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime()
  }
  const days = Math.round((startOfDay(new Date(iso).getTime()) - startOfDay(nowMs)) / 86_400_000)
  if (days !== 0 && days !== -1) return ''
  const text = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' }).format(days, 'day')
  return text.charAt(0).toUpperCase() + text.slice(1)
}

export function formatClock(locale: string, iso: string): string {
  return new Intl.DateTimeFormat(locale, { timeStyle: 'short' }).format(new Date(iso))
}

/** "2 h 5 min" or "45 min". */
export function formatRunTime(t: Translate, session: SessionSummary, nowMs: number): string {
  const end = session.closedAt ? new Date(session.closedAt).getTime() : nowMs
  const minutes = Math.max(0, Math.round((end - new Date(session.openedAt).getTime()) / 60000))
  return minutes < 60
    ? t('historyDurationM', { minutes })
    : t('historyDurationHM', { hours: Math.floor(minutes / 60), minutes: minutes % 60 })
}

export function isForceClosed(session: SessionSummary): boolean {
  return Boolean(session.closedAt) && Boolean(session.closeReason?.trim())
}

/** Tokens that were never seen: still waiting, or called but never resolved. */
export function notSeen(counts: SessionSummary['counts']): number {
  return (counts.WAITING ?? 0) + (counts.CALLED ?? 0)
}

export function totalTokens(counts: SessionSummary['counts']): number {
  return Object.values(counts).reduce((sum, n) => sum + (n ?? 0), 0)
}

/** An amount in taka, e.g. "৳1,500" (the symbol and digits follow the language). */
export function formatBdt(locale: string, amount: number): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency: 'BDT',
    currencyDisplay: 'narrowSymbol',
    maximumFractionDigits: 0,
  }).format(amount)
}

/** A wait given in seconds, as "45 min" or "1 h 5 min"; under a minute counts as 1 min. */
export function formatWait(t: Translate, seconds: number): string {
  const minutes = Math.max(1, Math.round(seconds / 60))
  return minutes < 60
    ? t('historyDurationM', { minutes })
    : t('historyDurationHM', { hours: Math.floor(minutes / 60), minutes: minutes % 60 })
}
