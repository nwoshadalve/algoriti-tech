/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { PatientSummary, RegisterPatientInput, UpdatePatientInput } from '@/core/api/types'

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
