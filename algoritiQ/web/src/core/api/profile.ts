/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import { config } from '@/core/config'
import type { Account, ProfileInput } from '@/core/api/types'

export async function updateProfile(token: string, input: ProfileInput): Promise<Account> {
  const result = await apiFetch<{ account: Account }>('/me', {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.account
}

/** Sends the picture as it is; the tablet checks the type from the bytes. */
export async function uploadPhoto(token: string, picture: Blob): Promise<Account> {
  const result = await apiFetch<{ account: Account }>('/me/photo', {
    method: 'PUT',
    headers: { ...bearer(token), 'Content-Type': picture.type || 'image/jpeg' },
    body: picture,
  })
  return result.account
}

export async function removePhoto(token: string): Promise<Account> {
  const result = await apiFetch<{ account: Account }>('/me/photo', {
    method: 'DELETE',
    headers: bearer(token),
  })
  return result.account
}

/** Needs the current password; the tablet ends the account's other sign-ins. */
export async function changePassword(
  token: string,
  currentPassword: string,
  newPassword: string,
): Promise<void> {
  await apiFetch<void>('/me/password', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ currentPassword, newPassword }),
  })
}

/** The picture bytes. An `<img>` cannot send the token, so it is fetched here. */
export async function fetchPhoto(token: string): Promise<Blob> {
  const response = await fetch(`${config.apiBasePath}/me/photo`, { headers: bearer(token) })
  if (!response.ok) throw new Error('photo_unavailable')
  return response.blob()
}
