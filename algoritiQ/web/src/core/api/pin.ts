/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { PinDevice } from '@/core/api/types'

export async function listPinDevices(token: string): Promise<PinDevice[]> {
  const result = await apiFetch<{ devices: PinDevice[] }>('/me/pin', { headers: bearer(token) })
  return result.devices
}

export type NewPin = {
  /** The account password: a borrowed, unlocked browser must not be able to set a PIN. */
  password: string
  pin: string
  label: string
  /** This browser's earlier entry, replaced by the new one. */
  replaceDeviceId?: string
}

/** The secret comes back once; the browser keeps it, the tablet keeps only its hash. */
export async function setPin(
  token: string,
  input: NewPin,
): Promise<{ deviceToken: string; device: PinDevice }> {
  return apiFetch<{ deviceToken: string; device: PinDevice }>('/me/pin', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
}

export async function removePinDevice(token: string, deviceId: string): Promise<void> {
  await apiFetch<void>(`/me/pin/${deviceId}`, { method: 'DELETE', headers: bearer(token) })
}
