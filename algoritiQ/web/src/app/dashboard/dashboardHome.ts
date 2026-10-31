/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Role } from '@/core/api/types'

/** Default landing route after sign-in for this role. */
export function dashboardHomePath(role: Role): '/home' | '/board' {
  return role === 'receptionist' ? '/board' : '/home'
}
