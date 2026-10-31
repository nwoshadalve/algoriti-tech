/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { Chamber, ChamberInput, LicenseSummary } from '@/core/api/types'

export async function getLicense(token: string): Promise<LicenseSummary> {
  const result = await apiFetch<{ license: LicenseSummary }>('/license', { headers: bearer(token) })
  return result.license
}

export async function listChambers(token: string): Promise<Chamber[]> {
  const result = await apiFetch<{ chambers: Chamber[] }>('/chambers', { headers: bearer(token) })
  return result.chambers
}

export async function createChamber(token: string, input: ChamberInput): Promise<Chamber> {
  const result = await apiFetch<{ chamber: Chamber }>('/chambers', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.chamber
}

export async function updateChamber(
  token: string,
  chamberId: string,
  input: ChamberInput,
): Promise<Chamber> {
  const result = await apiFetch<{ chamber: Chamber }>(`/chambers/${chamberId}`, {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.chamber
}

export async function deleteChamber(token: string, chamberId: string): Promise<void> {
  await apiFetch<void>(`/chambers/${chamberId}`, { method: 'DELETE', headers: bearer(token) })
}
