/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Navigate } from 'react-router-dom'
import { ActivationCodePage } from '@/features/setup/ActivationCodePage'
import { AdminRegistrationPage } from '@/features/setup/AdminRegistrationPage'
import { ForgotPasswordPage } from '@/features/auth/ForgotPasswordPage'
import { OverviewPage } from '@/features/home/OverviewPage'
import { QueueDeskPage } from '@/features/home/QueueDeskPage'
import { DoctorPage } from '@/features/doctor/DoctorPage'
import { LicensePage } from '@/features/license/LicensePage'
import { SettingsPage } from '@/features/settings/SettingsPage'
import { LoginPage } from '@/features/auth/LoginPage'
import { MonitoringPage } from '@/features/monitoring/MonitoringPage'
import { BackupPage } from '@/features/backup/BackupPage'
import { QueueConfigurationPage } from '@/features/queue/QueueConfigurationPage'
import { AuditLogPage } from '@/features/audit/AuditLogPage'
import { AnalyticsPage } from '@/features/analytics/AnalyticsPage'
import { PatientsPage } from '@/features/patients/PatientsPage'
import { SessionHistoryPage } from '@/features/sessions/SessionHistoryPage'
import { SessionDetailPage } from '@/features/sessions/SessionDetailPage'
import { HelpPage } from '@/features/help/HelpPage'
import { UsersPage } from '@/features/dashboard/UsersPage'
import { WorkScopePage } from '@/features/work/WorkScopePage'
import { DashboardLayout } from '@/app/dashboard/DashboardLayout'
import { RequireAuth } from '@/app/RequireAuth'
import { AuthenticatedShell } from '@/app/AuthenticatedShell'
import { RequireWorkScopeReady } from '@/app/RequireWorkScopeReady'
import { RequireSetupComplete, RequireSetupIncomplete } from '@/app/SetupRouteGuards'
import { SignedInBootstrapGate } from '@/app/SignedInBootstrapGate'

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
                    element: <SignedInBootstrapGate />,
                    children: [
                      {
                        element: <DashboardLayout />,
                        children: [
                      { path: '/home', element: <OverviewPage /> },
                      { path: '/analytics', element: <AnalyticsPage /> },
                      { path: '/board', element: <Navigate to="/queue-desk" replace /> },
                      { path: '/queue-desk', element: <QueueDeskPage /> },
                      { path: '/patients', element: <PatientsPage /> },
                      { path: '/session-history', element: <SessionHistoryPage /> },
                      { path: '/session-history/:sessionId', element: <SessionDetailPage /> },
                      { path: '/doctor', element: <Navigate to="/config/doctor" replace /> },
                      { path: '/license', element: <Navigate to="/config/chamber" replace /> },
                      { path: '/config/doctor', element: <DoctorPage /> },
                      { path: '/config/chamber', element: <LicensePage /> },
                      { path: '/settings', element: <SettingsPage /> },
                      { path: '/users', element: <UsersPage /> },
                      { path: '/monitoring', element: <MonitoringPage /> },
                      { path: '/queue', element: <Navigate to="/config/queue" replace /> },
                      { path: '/config/queue', element: <QueueConfigurationPage /> },
                      { path: '/audit', element: <AuditLogPage /> },
                      { path: '/backup', element: <BackupPage /> },
                      { path: '/help', element: <HelpPage /> },
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
    ],
  },
]
