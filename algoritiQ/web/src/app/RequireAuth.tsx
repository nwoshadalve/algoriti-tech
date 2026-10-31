/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate, Outlet } from 'react-router-dom'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { useAuth } from '@/features/auth/authContext'

/** Dashboard routes — requires a valid session. */
export function RequireAuth() {
  const { state } = useAuth()

  if (state.status === 'loading') {
    return (
      <div className="flex min-h-dvh items-center justify-center bg-brand-mist dark:bg-brand-navy">
        <PagePreloader className="py-10" />
      </div>
    )
  }

  if (state.status === 'signedOut') {
    return <Navigate to="/login" replace />
  }

  return <Outlet />
}
