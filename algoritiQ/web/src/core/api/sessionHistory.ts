/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type {
  SessionDetail,
  SessionHistoryPage,
  SessionTokenQuery,
  TokenPage,
} from '@/core/api/types'

export type SessionHistoryFilter = {
  chamberId?: string
  /** ISO date-time: sessions opened at or after. */
  from?: string
  limit?: number
  offset?: number
}

/** Sessions, newest first. A receptionist only gets their own chambers. */
export async function listSessionHistory(
  token: string,
  filter: SessionHistoryFilter = {},
): Promise<SessionHistoryPage> {
  const params = new URLSearchParams()
  if (filter.chamberId) params.set('chamberId', filter.chamberId)
  if (filter.from) params.set('from', filter.from)
  if (filter.limit != null) params.set('limit', String(filter.limit))
  if (filter.offset != null) params.set('offset', String(filter.offset))
  const text = params.toString()
  return apiFetch<SessionHistoryPage>(`/queue-desk/sessions${text ? `?${text}` : ''}`, {
    headers: bearer(token),
  })
}

export async function getSessionDetail(token: string, sessionId: string): Promise<SessionDetail> {
  return apiFetch<SessionDetail>(`/queue-desk/sessions/${encodeURIComponent(sessionId)}`, {
    headers: bearer(token),
  })
}

/** One page of the patients of a past session. */
export async function listSessionTokens(
  token: string,
  sessionId: string,
  query: SessionTokenQuery = {},
): Promise<TokenPage> {
  const params = new URLSearchParams()
  if (query.search?.trim()) params.set('search', query.search.trim())
  if (query.status != null) params.set('status', query.status)
  if (query.sort != null) params.set('sort', query.sort)
  if (query.ascending === true) params.set('ascending', 'true')
  if (query.limit != null) params.set('limit', String(query.limit))
  if (query.offset != null) params.set('offset', String(query.offset))
  const text = params.toString()
  return apiFetch<TokenPage>(
    `/queue-desk/sessions/${encodeURIComponent(sessionId)}/tokens${text ? `?${text}` : ''}`,
    { headers: bearer(token) },
  )
}
