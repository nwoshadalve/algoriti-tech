/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

import { chambersQueryKeys } from '@/core/query/chambersQueryKeys'

/** Stable query keys for queue configuration ([queue-configuration.md]). */
export const queueQueryKeys = {
  all: ['queue'] as const,
  defaults: () => [...queueQueryKeys.all, 'defaults'] as const,
  chambers: () => chambersQueryKeys.list(),
  chamber: (chamberId: string) => [...queueQueryKeys.all, 'chamber', chamberId] as const,
}
