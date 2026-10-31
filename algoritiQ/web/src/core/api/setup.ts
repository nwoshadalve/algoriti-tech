/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch } from '@/core/api/client'
import type { Account, RegisterAdminRequest, SetupStatus } from '@/core/api/types'
import { normalizeClaimCode } from '@/features/setup/adminRegistrationValidation'

export async function getSetupStatus(): Promise<SetupStatus> {
  return apiFetch<SetupStatus>('/setup/status')
}

export async function verifyClaimCode(claimCode: string): Promise<void> {
  await apiFetch<{ valid: true }>('/setup/claim/verify', {
    method: 'POST',
    body: JSON.stringify({ claimCode: normalizeClaimCode(claimCode) }),
  })
}

export async function registerAdmin(body: RegisterAdminRequest): Promise<Account> {
  const result = await apiFetch<{ account: Account }>('/setup/admin', {
    method: 'POST',
    body: JSON.stringify(body),
  })
  return result.account
}
