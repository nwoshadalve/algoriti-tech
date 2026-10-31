/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Outlet } from 'react-router-dom'
import { BootstrapScreen } from '@/app/BootstrapScreen'
import { useClinic } from '@/core/clinic/clinicContext'
import { useAuth } from '@/features/auth/authContext'
import { useWorkScope } from '@/features/work/workScopeContext'

/** Hides dashboard chrome until the signed-in shell has everything it needs to render. */
export function SignedInBootstrapGate() {
  const { state: auth } = useAuth()
  const { state: work } = useWorkScope()
  const { licenseType } = useClinic()

  if (auth.status !== 'signedIn') {
    return <BootstrapScreen />
  }

  if (
    auth.account.role === 'receptionist' &&
    (work.status === 'idle' || work.status === 'loading')
  ) {
    return <BootstrapScreen />
  }

  if (licenseType === undefined) {
    return <BootstrapScreen />
  }

  return <Outlet />
}
