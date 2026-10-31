/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import { config } from '@/core/config'
import type { Doctor, DoctorInput, LicenseType } from '@/core/api/types'

/** What the clinic is licensed for; null when no valid license is stored. */
export async function getLicenseType(token: string): Promise<LicenseType | null> {
  const result = await apiFetch<{ licenseType: LicenseType | null }>('/clinic', {
    headers: bearer(token),
  })
  return result.licenseType
}

export async function getDoctor(token: string): Promise<Doctor> {
  const result = await apiFetch<{ doctor: Doctor }>('/doctor', { headers: bearer(token) })
  return result.doctor
}

export async function saveDoctor(token: string, input: DoctorInput): Promise<Doctor> {
  const result = await apiFetch<{ doctor: Doctor }>('/doctor', {
    method: 'PUT',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.doctor
}

export async function uploadDoctorPhoto(token: string, picture: Blob): Promise<Doctor> {
  const result = await apiFetch<{ doctor: Doctor }>('/doctor/photo', {
    method: 'PUT',
    headers: { ...bearer(token), 'Content-Type': picture.type || 'image/jpeg' },
    body: picture,
  })
  return result.doctor
}

export async function removeDoctorPhoto(token: string): Promise<Doctor> {
  const result = await apiFetch<{ doctor: Doctor }>('/doctor/photo', {
    method: 'DELETE',
    headers: bearer(token),
  })
  return result.doctor
}

export async function fetchDoctorPhoto(token: string): Promise<Blob> {
  const response = await fetch(`${config.apiBasePath}/doctor/photo`, { headers: bearer(token) })
  if (!response.ok) throw new Error('photo_unavailable')
  return response.blob()
}
