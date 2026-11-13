/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type {
  PatientListPage,
  PatientListQuery,
  PatientSummary,
  RegisterPatientInput,
  UpdatePatientInput,
} from '@/core/api/types'

/** One page of the patient list: searched, filtered and sorted on the tablet. */
export async function listPatients(
  token: string,
  query: PatientListQuery = {},
): Promise<PatientListPage> {
  const params = new URLSearchParams()
  if (query.search?.trim()) params.set('search', query.search.trim())
  if (query.gender) params.set('gender', query.gender)
  if (query.paperFileOnly) params.set('paperFileOnly', 'true')
  if (query.sort) params.set('sort', query.sort)
  if (query.ascending) params.set('ascending', 'true')
  if (query.limit != null) params.set('limit', String(query.limit))
  if (query.offset != null) params.set('offset', String(query.offset))
  const text = params.toString()
  return apiFetch<PatientListPage>(`/patients${text ? `?${text}` : ''}`, { headers: bearer(token) })
}

export async function searchPatients(token: string, query: string): Promise<PatientSummary[]> {
  const result = await apiFetch<{ patients: PatientSummary[] }>('/patients/search', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ query }),
  })
  return result.patients
}

export async function registerPatient(
  token: string,
  input: RegisterPatientInput,
): Promise<PatientSummary> {
  return apiFetch<PatientSummary>('/patients', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
}

export async function updatePatient(
  token: string,
  patientId: string,
  input: UpdatePatientInput,
): Promise<PatientSummary> {
  return apiFetch<PatientSummary>(`/patients/${encodeURIComponent(patientId)}`, {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
}
