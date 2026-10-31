/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate, Outlet } from 'react-router-dom'
import { BootstrapScreen } from '@/app/BootstrapScreen'
import { RegisteredClinicRedirect } from '@/app/RegisteredClinicRedirect'
import { useAdminRegistered } from '@/features/auth/useAdminRegistered'

/** Activation and registration only — until the first admin exists. */
export function RequireSetupIncomplete() {
  const setup = useAdminRegistered()
  if (setup === 'loading') return <BootstrapScreen />
  if (setup === 'registered') return <RegisteredClinicRedirect />
  return <Outlet />
}

/** Sign-in, password reset, and home — not available during first-time setup. */
export function RequireSetupComplete() {
  const setup = useAdminRegistered()
  if (setup === 'loading') return <BootstrapScreen />
  if (setup !== 'registered') return <Navigate to="/" replace />
  return <Outlet />
}
