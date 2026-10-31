/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Outlet } from 'react-router-dom'
import { ClinicProvider } from '@/core/clinic/ClinicProvider'
import { WorkScopeProvider } from '@/features/work/WorkScopeProvider'

/** Signed-in routes that may need receptionist work-scope state. */
export function AuthenticatedShell() {
  return (
    <ClinicProvider>
      <WorkScopeProvider>
        <Outlet />
      </WorkScopeProvider>
    </ClinicProvider>
  )
}
