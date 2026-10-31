/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { UsersQuery } from '@/core/api/types'

/** Users admin table and create/edit context ([/users]). */
export const usersQueryKeys = {
  all: ['users'] as const,
  context: () => [...usersQueryKeys.all, 'context'] as const,
  list: (query: UsersQuery) =>
    [
      ...usersQueryKeys.all,
      'list',
      query.search.trim(),
      query.role,
      query.status,
      query.sort,
      query.dir,
    ] as const,
}
