/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** License summary on `/config/chamber` (chamber list uses `chambersQueryKeys`). */
export const licenseQueryKeys = {
  all: ['license'] as const,
  summary: () => [...licenseQueryKeys.all, 'summary'] as const,
}
