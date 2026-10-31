/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { getSetupStatus } from '@/core/api/setup'

export type SetupPhase = 'loading' | 'open' | 'registered' | 'unknown'

/**
 * Whether the clinic already has an admin: pages for signed-out visitors send
 * them to the setup steps (`open`) or to sign-in (`registered`).
 */
export function useAdminRegistered(): SetupPhase {
  const [phase, setPhase] = useState<SetupPhase>('loading')

  useEffect(() => {
    let cancelled = false
    void getSetupStatus().then(
      (status) => {
        if (!cancelled) setPhase(status.adminRegistered ? 'registered' : 'open')
      },
      () => {
        if (!cancelled) setPhase('unknown')
      },
    )
    return () => {
      cancelled = true
    }
  }, [])

  return phase
}
