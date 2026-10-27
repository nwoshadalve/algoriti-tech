import { apiFetch, bearer } from '@/core/api/client'
import type { Account, LoginResult, ResetStartResult } from '@/core/api/types'

export async function login(username: string, password: string): Promise<LoginResult> {
  return apiFetch<LoginResult>('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ username: username.trim().toLowerCase(), password }),
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
