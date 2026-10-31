/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate } from 'react-router-dom'
import { BootstrapScreen } from '@/app/BootstrapScreen'
import { dashboardHomePath } from '@/app/dashboard/dashboardHome'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'

/**
 * After setup, `/` should not strand people on activation or force sign-in when a
 * remembered session is still valid.
 */
export function RegisteredClinicRedirect() {
  const { state } = useAuth()
  const restoring = readSession() !== null || state.status === 'loading'

  if (restoring) {
    if (state.status === 'loading') {
      return <BootstrapScreen />
    }
    if (state.status === 'signedIn') {
      return <Navigate to={dashboardHomePath(state.account.role)} replace />
    }
  }

  return <Navigate to="/login" replace />
}
