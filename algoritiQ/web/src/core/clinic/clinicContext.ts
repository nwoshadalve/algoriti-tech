/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { createContext, useContext } from 'react'
import type { LicenseType } from '@/core/api/types'

/** `undefined` while it is being asked; null when the tablet holds no valid license. */
export type ClinicInfo = { licenseType: LicenseType | null | undefined }

export const ClinicContext = createContext<ClinicInfo>({ licenseType: undefined })

export function useClinic(): ClinicInfo {
  return useContext(ClinicContext)
}
