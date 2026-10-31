/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useMemo, useState, type ReactNode } from 'react'
import { getLicenseType } from '@/core/api/doctor'
import { ClinicContext, type ClinicInfo } from '@/core/clinic/clinicContext'
import { readSession } from '@/features/auth/session'

/** Asks the tablet once what the clinic is licensed for, so the menu can show the right pages. */
export function ClinicProvider({ children }: { children: ReactNode }) {
  const [licenseType, setLicenseType] = useState<ClinicInfo['licenseType']>(undefined)

  useEffect(() => {
    const token = readSession()
    if (!token) return
    let cancelled = false
    getLicenseType(token).then(
      (type) => {
        if (!cancelled) setLicenseType(type)
      },
      () => {
        if (!cancelled) setLicenseType(null)
      },
    )
    return () => {
      cancelled = true
    }
  }, [])

  const value = useMemo(() => ({ licenseType }), [licenseType])
  return <ClinicContext.Provider value={value}>{children}</ClinicContext.Provider>
}
