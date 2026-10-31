/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Doctor license profile shown on `/config/doctor`. */
export const doctorQueryKeys = {
  all: ['doctor'] as const,
  detail: () => [...doctorQueryKeys.all, 'detail'] as const,
}
