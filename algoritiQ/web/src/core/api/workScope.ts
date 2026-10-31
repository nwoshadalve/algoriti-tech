/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'

export type AssignmentTarget = 'chamber' | 'doctor'

export type WorkScopeOption = {
  id: string
  name: string
  detail: string
}

export type WorkScopesResponse = {
  assignmentTarget: AssignmentTarget
  assignmentCount: number
  options: WorkScopeOption[]
}

/** Chambers or doctors assigned to the signed-in receptionist. */
export async function getWorkScopes(token: string): Promise<WorkScopesResponse> {
  return apiFetch<WorkScopesResponse>('/me/work-scopes', { headers: bearer(token) })
}
