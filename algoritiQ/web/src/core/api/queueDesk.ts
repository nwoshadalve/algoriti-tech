/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, ApiError, bearer } from '@/core/api/client'
import type {
  BoardSnapshot,
  BoardTokenView,
  IssuePreview,
  IssuedTokenResult,
  RegisterPatientInput,
  SessionTokenQuery,
  TokenPage,
} from '@/core/api/types'

function chamberPath(chamberId: string): string {
  return `/queue-desk/chambers/${encodeURIComponent(chamberId)}`
}

function sessionTokenQueryString(query: SessionTokenQuery): string {
  const params = new URLSearchParams()
  if (query.search != null && query.search !== '') params.set('search', query.search)
  if (query.status != null) params.set('status', query.status)
  if (query.queueTypeId != null && query.queueTypeId !== '') {
    params.set('queueTypeId', query.queueTypeId)
  }
  if (query.notPrintedOnly === true) params.set('notPrintedOnly', 'true')
  if (query.sort != null) params.set('sort', query.sort)
  if (query.ascending === true) params.set('ascending', 'true')
  if (query.limit != null) params.set('limit', String(query.limit))
  if (query.offset != null) params.set('offset', String(query.offset))
  const text = params.toString()
  return text ? `?${text}` : ''
}

/** Live queue desk snapshot for one chamber ([patient-entry-and-queue-operations.md]). */
export async function getQueueDeskSnapshot(
  token: string,
  chamberId: string,
  options?: { includeTokens?: boolean },
): Promise<BoardSnapshot> {
  const includeTokens = options?.includeTokens ?? true
  const query = includeTokens ? '' : '?includeTokens=false'
  return apiFetch<BoardSnapshot>(`${chamberPath(chamberId)}${query}`, { headers: bearer(token) })
}

/** One page of the session table (search, filter, sort on the server). */
export async function searchSessionTokens(
  token: string,
  chamberId: string,
  query: SessionTokenQuery = {},
): Promise<TokenPage> {
  return apiFetch<TokenPage>(
    `${chamberPath(chamberId)}/session/tokens${sessionTokenQueryString(query)}`,
    { headers: bearer(token) },
  )
}

/**
 * Uses `session/tokens` when the tablet API supports it; otherwise reads tokens
 * from a full snapshot (older app builds before the paginated route existed).
 */
export async function searchSessionTokensCompat(
  token: string,
  chamberId: string,
  query: SessionTokenQuery = {},
): Promise<TokenPage> {
  try {
    return await searchSessionTokens(token, chamberId, query)
  } catch (error) {
    if (!(error instanceof ApiError) || error.code !== 'not_found') {
      throw error
    }
    const snapshot = await getQueueDeskSnapshot(token, chamberId, { includeTokens: true })
    const offset = query.offset ?? 0
    const limit = query.limit ?? 30
    const items = snapshot.tokens.slice(offset, offset + limit)
    return { items, total: snapshot.tokens.length, counts: {} }
  }
}

/** Prefer a chamber that already has an open session (admin queue desk picker). */
export async function pickChamberIdWithOpenSession(
  token: string,
  chambers: { id: string }[],
): Promise<string> {
  if (chambers.length === 0) return ''
  for (const chamber of chambers) {
    try {
      const snapshot = await getQueueDeskSnapshot(token, chamber.id, { includeTokens: false })
      if (snapshot.sessionOpen) return chamber.id
    } catch {
      // try next chamber
    }
  }
  return chambers[0]!.id
}

export async function startQueueDeskSession(token: string, chamberId: string): Promise<void> {
  await apiFetch(`${chamberPath(chamberId)}/session/start`, {
    method: 'POST',
    headers: bearer(token),
  })
}

export async function previewIssueToken(
  token: string,
  chamberId: string,
  patientId: string,
  queueTypeId: string,
  feeBdt?: number | null,
): Promise<IssuePreview> {
  return apiFetch<IssuePreview>(`${chamberPath(chamberId)}/issue-preview`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ patientId, queueTypeId, feeBdt: feeBdt ?? undefined }),
  })
}

export async function issueToken(
  token: string,
  chamberId: string,
  input: {
    commandId: string
    patientId: string
    queueTypeId: string
    feeBdt?: number | null
  },
): Promise<IssuedTokenResult> {
  return apiFetch<IssuedTokenResult>(`${chamberPath(chamberId)}/issue`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
}

/** Save a new patient and issue their first token in one transaction (tablet desk flow). */
export async function registerAndIssueToken(
  token: string,
  chamberId: string,
  input: RegisterPatientInput & { queueTypeId: string; feeBdt?: number | null },
): Promise<IssuedTokenResult> {
  return apiFetch<IssuedTokenResult>(`${chamberPath(chamberId)}/register-and-issue`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
}

export async function callNextToken(
  token: string,
  chamberId: string,
  commandId: string,
  queueTypeId: string,
): Promise<BoardTokenView> {
  return apiFetch<BoardTokenView>(`${chamberPath(chamberId)}/call-next`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId, queueTypeId }),
  })
}

export async function recallCalledToken(
  token: string,
  chamberId: string,
  commandId: string,
  queueTypeId: string,
): Promise<void> {
  await apiFetch(`${chamberPath(chamberId)}/recall`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId, queueTypeId }),
  })
}

export async function markTokenEntered(
  token: string,
  tokenId: string,
  commandId: string,
): Promise<BoardTokenView> {
  return apiFetch<BoardTokenView>(`/queue-desk/tokens/${encodeURIComponent(tokenId)}/entered`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId }),
  })
}

export async function markTokenSkipped(
  token: string,
  tokenId: string,
  commandId: string,
): Promise<BoardTokenView> {
  return apiFetch<BoardTokenView>(`/queue-desk/tokens/${encodeURIComponent(tokenId)}/skipped`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId }),
  })
}

export async function cancelToken(
  token: string,
  tokenId: string,
  commandId: string,
  reason?: string,
): Promise<BoardTokenView> {
  return apiFetch<BoardTokenView>(`/queue-desk/tokens/${encodeURIComponent(tokenId)}/cancel`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId, reason }),
  })
}

export async function sendTokenPrint(
  token: string,
  tokenId: string,
  printAttemptId: string,
): Promise<{ printResult: string }> {
  return apiFetch<{ printResult: string }>(
    `/queue-desk/tokens/${encodeURIComponent(tokenId)}/print`,
    {
      method: 'POST',
      headers: bearer(token),
      body: JSON.stringify({ printAttemptId }),
    },
  )
}

export async function reprintToken(
  token: string,
  tokenId: string,
  commandId: string,
  reason: string,
): Promise<{ printAttemptId: string }> {
  return apiFetch<{ printAttemptId: string }>(
    `/queue-desk/tokens/${encodeURIComponent(tokenId)}/reprint`,
    {
      method: 'POST',
      headers: bearer(token),
      body: JSON.stringify({ commandId, reason }),
    },
  )
}
