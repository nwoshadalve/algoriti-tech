/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { Account, LoginResult, ResetStartResult } from '@/core/api/types'

export async function login(
  username: string,
  password: string,
  remember = false,
): Promise<LoginResult> {
  return apiFetch<LoginResult>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username: username.trim().toLowerCase(), password, remember }),
  })
}

/** Signs in with the PIN of this browser; needs the secret the tablet gave when the PIN was set. */
export async function loginWithPin(deviceToken: string, pin: string): Promise<LoginResult> {
  return apiFetch<LoginResult>('/auth/pin/login', {
    method: 'POST',
    body: JSON.stringify({ deviceToken, pin }),
  })
}

export async function logout(token: string): Promise<void> {
  await apiFetch<void>('/auth/logout', { method: 'POST', headers: bearer(token) })
}

export async function getMe(token: string): Promise<Account> {
  const result = await apiFetch<{ account: Account }>('/me', { headers: bearer(token) })
  return result.account
}

/** Step 1 of a forgotten-password reset: prove the tablet's activation key. */
export async function startPasswordReset(
  username: string,
  activationKey: string,
): Promise<ResetStartResult> {
  return apiFetch<ResetStartResult>('/auth/password/reset/start', {
    method: 'POST',
    body: JSON.stringify({ username: username.trim().toLowerCase(), activationKey }),
  })
}

/** Step 2: choose the new password with the ticket from step 1. */
export async function finishPasswordReset(resetToken: string, newPassword: string): Promise<void> {
  await apiFetch<void>('/auth/password/reset', {
    method: 'POST',
    body: JSON.stringify({ resetToken, newPassword }),
  })
}
