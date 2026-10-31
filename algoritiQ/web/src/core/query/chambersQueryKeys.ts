/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Shared list of clinic chambers (license page, queue config, users, board). */
export const chambersQueryKeys = {
  all: ['chambers'] as const,
  list: () => [...chambersQueryKeys.all, 'list'] as const,
}
