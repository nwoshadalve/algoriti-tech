/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { TokenSort, TokenStatus } from '@/core/api/types'

export const sessionHistoryQueryKeys = {
  all: ['session-history'] as const,
  list: (chamberId: string, from: string) =>
    [...sessionHistoryQueryKeys.all, 'list', chamberId, from] as const,
  detail: (sessionId: string) => [...sessionHistoryQueryKeys.all, 'detail', sessionId] as const,
  tokens: (
    sessionId: string,
    status: TokenStatus | '',
    search: string,
    sort: TokenSort,
    ascending: boolean,
  ) => [...sessionHistoryQueryKeys.all, 'tokens', sessionId, status, search, sort, ascending] as const,
}
