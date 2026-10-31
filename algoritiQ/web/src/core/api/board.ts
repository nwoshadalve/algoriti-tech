/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { BoardSnapshot, BoardTokenView, IssuePreview, IssuedTokenResult } from '@/core/api/types'

function chamberPath(chamberId: string): string {
  return `/queue-board/chambers/${encodeURIComponent(chamberId)}`
}

export async function getBoardSnapshot(token: string, chamberId: string): Promise<BoardSnapshot> {
  return apiFetch<BoardSnapshot>(chamberPath(chamberId), { headers: bearer(token) })
}

export async function startBoardSession(token: string, chamberId: string): Promise<void> {
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
  return apiFetch<BoardTokenView>(`/queue-board/tokens/${encodeURIComponent(tokenId)}/entered`, {
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
  return apiFetch<BoardTokenView>(`/queue-board/tokens/${encodeURIComponent(tokenId)}/skipped`, {
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
  return apiFetch<BoardTokenView>(`/queue-board/tokens/${encodeURIComponent(tokenId)}/cancel`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ commandId, reason }),
  })
}

export async function reprintToken(
  token: string,
  tokenId: string,
  commandId: string,
  reason: string,
): Promise<{ printAttemptId: string }> {
  return apiFetch<{ printAttemptId: string }>(
    `/queue-board/tokens/${encodeURIComponent(tokenId)}/reprint`,
    {
      method: 'POST',
      headers: bearer(token),
      body: JSON.stringify({ commandId, reason }),
    },
  )
}
