/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate, Outlet } from 'react-router-dom'
import { SetupLayout } from '@/app/SetupLayout'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SetupCard } from '@/core/ui/SetupCard'
import { useAdminRegistered } from '@/features/auth/useAdminRegistered'

function GuardLoading() {
  return (
    <SetupLayout>
      <SetupCard labelledBy="route-guard-loading">
        <PagePreloader className="py-10" />
      </SetupCard>
    </SetupLayout>
  )
}

/** Activation and registration only — until the first admin exists. */
export function RequireSetupIncomplete() {
  const setup = useAdminRegistered()
  if (setup === 'loading') return <GuardLoading />
  if (setup === 'registered') return <Navigate to="/login" replace />
  return <Outlet />
}

/** Sign-in, password reset, and home — not available during first-time setup. */
export function RequireSetupComplete() {
  const setup = useAdminRegistered()
  if (setup === 'loading') return <GuardLoading />
  if (setup !== 'registered') return <Navigate to="/" replace />
  return <Outlet />
}
