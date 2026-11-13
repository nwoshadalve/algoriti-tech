/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'

/** A fee the admin defined: the code a receptionist picks, and the amount it stands for. */
export type FeeCode = {
  id: string
  code: string
  amountBdt: number
}

/** A code on its way to the tablet; a new one has no id yet. */
export type FeeCodeInput = {
  id?: string
  code: string
  amountBdt: number
}

export async function getFeeCodes(token: string): Promise<FeeCode[]> {
  const result = await apiFetch<{ codes: FeeCode[] }>('/fee-codes', { headers: bearer(token) })
  return result.codes
}

/** Replaces the whole list (an empty list removes every code). */
export async function saveFeeCodes(token: string, codes: FeeCodeInput[]): Promise<FeeCode[]> {
  const result = await apiFetch<{ codes: FeeCode[] }>('/fee-codes', {
    method: 'PUT',
    headers: bearer(token),
    body: JSON.stringify({ codes }),
  })
  return result.codes
}
