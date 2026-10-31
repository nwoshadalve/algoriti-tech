/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Cached profile blobs keyed by scope (account vs doctor) and `photoVersion`. */
export const avatarQueryKeys = {
  all: ['avatar'] as const,
  blob: (scope: string, photoVersion: number) =>
    [...avatarQueryKeys.all, scope, photoVersion] as const,
}
