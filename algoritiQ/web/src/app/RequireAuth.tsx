/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate, Outlet } from 'react-router-dom'
import { BootstrapScreen } from '@/app/BootstrapScreen'
import { useAuth } from '@/features/auth/authContext'

/** Dashboard routes — requires a valid session. */
export function RequireAuth() {
  const { state } = useAuth()

  if (state.status === 'loading') {
    return <BootstrapScreen />
  }

  if (state.status === 'signedOut') {
    return <Navigate to="/login" replace />
  }

  return <Outlet />
}
