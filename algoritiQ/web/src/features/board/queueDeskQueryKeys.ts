/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { SessionTokenQuery } from '@/core/api/types'

/** Stable query keys for the queue desk board. */
export const queueDeskQueryKeys = {
  all: ['queueDesk'] as const,
  snapshot: (chamberId: string) => [...queueDeskQueryKeys.all, 'snapshot', chamberId] as const,
  tokens: (chamberId: string, query: SessionTokenQuery) =>
    [...queueDeskQueryKeys.all, 'tokens', chamberId, query] as const,
}

export const defaultSessionTokenQuery: SessionTokenQuery = {
  limit: 30,
  offset: 0,
  sort: 'issued',
  ascending: false,
}

/** Query identity for infinite scroll (offset/limit are per request). */
export function sessionTokensListKey(
  chamberId: string,
  query: Omit<SessionTokenQuery, 'offset' | 'limit'>,
) {
  return [...queueDeskQueryKeys.all, 'tokens', chamberId, query] as const
}
