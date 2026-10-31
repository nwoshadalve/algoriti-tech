/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Live health snapshot from `/monitoring` ([/monitoring]). */
export const monitoringQueryKeys = {
  all: ['monitoring'] as const,
  snapshot: () => [...monitoringQueryKeys.all, 'snapshot'] as const,
}
