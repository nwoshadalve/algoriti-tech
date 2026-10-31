/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { ActivationCodePage } from '@/features/setup/ActivationCodePage'
import { AdminRegistrationPage } from '@/features/setup/AdminRegistrationPage'
import { ForgotPasswordPage } from '@/features/auth/ForgotPasswordPage'
import { OverviewPage } from '@/features/home/OverviewPage'
import { BoardPage } from '@/features/home/BoardPage'
import { DoctorPage } from '@/features/doctor/DoctorPage'
import { LicensePage } from '@/features/license/LicensePage'
import { SettingsPage } from '@/features/settings/SettingsPage'
import { LoginPage } from '@/features/auth/LoginPage'
import { MonitoringPage } from '@/features/monitoring/MonitoringPage'
import { BackupPage } from '@/features/backup/BackupPage'
import { UsersPage } from '@/features/dashboard/UsersPage'
import { WorkScopePage } from '@/features/work/WorkScopePage'
import { DashboardLayout } from '@/app/dashboard/DashboardLayout'
import { RequireAuth } from '@/app/RequireAuth'
import { AuthenticatedShell } from '@/app/AuthenticatedShell'
import { RequireWorkScopeReady } from '@/app/RequireWorkScopeReady'
import { RequireSetupComplete, RequireSetupIncomplete } from '@/app/SetupRouteGuards'

/** Shared route tree for the browser router and tests. */
export const appRoutes = [
  {
    element: <RequireSetupIncomplete />,
    children: [
      { path: '/', element: <ActivationCodePage /> },
      { path: '/register', element: <AdminRegistrationPage /> },
    ],
  },
  {
    element: <RequireSetupComplete />,
    children: [
      { path: '/login', element: <LoginPage /> },
      { path: '/forgot-password', element: <ForgotPasswordPage /> },
      {
        element: <RequireAuth />,
        children: [
          {
            element: <AuthenticatedShell />,
            children: [
              { path: '/work', element: <WorkScopePage /> },
              {
                element: <RequireWorkScopeReady />,
                children: [
                  {
                    element: <DashboardLayout />,
                    children: [
                      { path: '/home', element: <OverviewPage /> },
                      { path: '/board', element: <BoardPage /> },
                      { path: '/doctor', element: <DoctorPage /> },
                      { path: '/license', element: <LicensePage /> },
                      { path: '/settings', element: <SettingsPage /> },
                      { path: '/users', element: <UsersPage /> },
                      { path: '/monitoring', element: <MonitoringPage /> },
                      { path: '/backup', element: <BackupPage /> },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
]
