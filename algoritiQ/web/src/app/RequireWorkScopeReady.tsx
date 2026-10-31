/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate, Outlet, useLocation } from 'react-router-dom'
import { useAuth } from '@/features/auth/authContext'
import { useWorkScope, workScopeBlocksDashboard } from '@/features/work/workScopeContext'

/** Dashboard routes — receptionists need a work scope first. */
export function RequireWorkScopeReady() {
  const { state: auth } = useAuth()
  const { state } = useWorkScope()
  const { pathname } = useLocation()

  if (auth.status !== 'signedIn') {
    return <Outlet />
  }

  if (auth.account.role !== 'receptionist') {
    return <Outlet />
  }

  if (state.status === 'idle' || state.status === 'loading') {
    return <Outlet />
  }

  if (workScopeBlocksDashboard(state) && pathname !== '/work') {
    return <Navigate to="/work" replace />
  }

  return <Outlet />
}
