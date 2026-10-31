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
import {
  readLicenseCache,
  writeLicenseCache,
} from '@/core/clinic/clinicLicenseCache'
import { readSession } from '@/features/auth/session'

/** Keeps clinic license in sync with the tablet so the menu does not reflow after load. */
export function ClinicProvider({ children }: { children: ReactNode }) {
  const [licenseType, setLicenseType] = useState<ClinicInfo['licenseType']>(() => readLicenseCache())

  useEffect(() => {
    const token = readSession()
    if (!token) return
    let cancelled = false
    getLicenseType(token).then(
      (type) => {
        if (cancelled) return
        writeLicenseCache(type)
        setLicenseType(type)
      },
      () => {
        if (cancelled) return
        writeLicenseCache(null)
        setLicenseType(null)
      },
    )
    return () => {
      cancelled = true
    }
  }, [])

  const value = useMemo(() => ({ licenseType }), [licenseType])
  return <ClinicContext.Provider value={value}>{children}</ClinicContext.Provider>
}
