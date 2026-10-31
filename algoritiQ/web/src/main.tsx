/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 *
 * @file React entry — theme, locale, auth, and global error/toast shells before routing.
 */
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ThemeProvider } from '@/core/theme/ThemeProvider'
import { ErrorBoundary } from '@/app/ErrorBoundary'
import { ToastProvider } from '@/core/toast/ToastProvider'
import { AuthProvider } from '@/features/auth/AuthProvider'
import { QueryProvider } from '@/core/query/QueryProvider'
import './index.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <ThemeProvider>
      <LocaleProvider>
        <ErrorBoundary>
          <ToastProvider>
            <AuthProvider>
              <QueryProvider>
                <App />
              </QueryProvider>
            </AuthProvider>
          </ToastProvider>
        </ErrorBoundary>
      </LocaleProvider>
    </ThemeProvider>
  </StrictMode>,
)
