import { render, type RenderOptions } from '@testing-library/react'
import { createMemoryRouter, RouterProvider } from 'react-router-dom'
import type { ReactElement } from 'react'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ThemeProvider } from '@/core/theme/ThemeProvider'
import { AuthProvider } from '@/features/auth/AuthProvider'
import { appRoutes } from '@/app/appRoutes'

type Options = Omit<RenderOptions, 'wrapper'> & {
  route?: string
}

function AppProviders({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider>
      <LocaleProvider>
        <AuthProvider>{children}</AuthProvider>
      </LocaleProvider>
    </ThemeProvider>
  )
}

/** Renders a page within the real app routes (activation + register). */
export function renderAppAt(route = '/') {
  const router = createMemoryRouter(appRoutes, { initialEntries: [route] })
  return render(
    <AppProviders>
      <RouterProvider router={router} />
    </AppProviders>,
  )
}

/** Renders a single component without the app router (unit-style). */
export function renderWithRouter(ui: ReactElement, { route = '/', ...options }: Options = {}) {
  const router = createMemoryRouter([{ path: '*', element: ui }], { initialEntries: [route] })
  return render(
    <AppProviders>
      <RouterProvider router={router} />
    </AppProviders>,
    options,
  )
}
