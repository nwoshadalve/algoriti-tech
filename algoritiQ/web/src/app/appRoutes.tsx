import { ActivationCodePage } from '@/features/setup/ActivationCodePage'
import { AdminRegistrationPage } from '@/features/setup/AdminRegistrationPage'
import { ForgotPasswordPage } from '@/features/auth/ForgotPasswordPage'
import { HomePage } from '@/features/auth/HomePage'
import { LoginPage } from '@/features/auth/LoginPage'
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
      { path: '/home', element: <HomePage /> },
    ],
  },
]
