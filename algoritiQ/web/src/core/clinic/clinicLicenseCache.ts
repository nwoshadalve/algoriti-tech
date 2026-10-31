/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { LicenseType } from '@/core/api/types'

const storageKey = 'algoritiq.clinicLicense'

/** Last known clinic license for stable navigation before `/clinic` returns. */
export function readLicenseCache(): LicenseType | null | undefined {
  try {
    const raw = sessionStorage.getItem(storageKey)
    if (raw === 'doctor' || raw === 'chamber') return raw
    if (raw === 'none') return null
  } catch {
    /* private mode */
  }
  return undefined
}

export function writeLicenseCache(licenseType: LicenseType | null): void {
  try {
    sessionStorage.setItem(storageKey, licenseType ?? 'none')
  } catch {
    /* private mode */
  }
}

export function clearLicenseCache(): void {
  try {
    sessionStorage.removeItem(storageKey)
  } catch {
    /* private mode */
  }
}

/** React state or cache; while both are missing, navigation stays stable for doctor-license items. */
export function effectiveLicenseType(
  licenseType: LicenseType | null | undefined,
): LicenseType | null | undefined {
  if (licenseType !== undefined) return licenseType
  return readLicenseCache()
}
