/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useId, useState } from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import { DashboardNavbar } from '@/app/dashboard/DashboardNavbar'
import { DashboardSidebar } from '@/app/dashboard/DashboardSidebar'
import { LiveChannelProvider } from '@/core/api/LiveChannelProvider'
import { ClinicProvider } from '@/core/clinic/ClinicProvider'
import { useAuth } from '@/features/auth/authContext'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useWorkScope } from '@/features/work/workScopeContext'

/**
 * Signed-in app chrome. Desktop (`lg`+): a fixed full-height sidebar and the page
 * beside it. Phones and tablets: a slim top bar and the sidebar as a drawer.
 */
export function DashboardLayout() {
  const sidebarId = useId()
  const { pathname } = useLocation()
  const { t } = useLocale()
  const { state, signOut } = useAuth()
  const { canChangeWorkScope, reopenChoice } = useWorkScope()
  const [mobileNavOpen, setMobileNavOpen] = useState(false)
  const [signingOut, setSigningOut] = useState(false)

  const closeMobile = useCallback(() => setMobileNavOpen(false), [])
  const toggleMobile = useCallback(() => setMobileNavOpen((open) => !open), [])

  useEffect(() => {
    closeMobile()
  }, [pathname, closeMobile])

  useEffect(() => {
    if (!mobileNavOpen) return
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') closeMobile()
    }
    document.addEventListener('keydown', onKeyDown)
    document.body.classList.add('overflow-hidden')
    return () => {
      document.removeEventListener('keydown', onKeyDown)
      document.body.classList.remove('overflow-hidden')
    }
  }, [mobileNavOpen, closeMobile])

  async function onSignOut() {
    setSigningOut(true)
    await signOut()
  }

  const account = state.status === 'signedIn' ? state.account : null

  return (
    <LiveChannelProvider>
      <ClinicProvider>
      <div className="min-h-dvh bg-brand-mist text-brand-navy dark:bg-brand-navy dark:text-white">
        <a
          href="#dashboard-main"
          className="sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:z-[60] focus:rounded-lg focus:bg-white focus:px-3 focus:py-2 focus:text-sm focus:font-medium focus:text-brand-navy focus:shadow-lg dark:focus:bg-brand-navy-raised dark:focus:text-white"
        >
          {t('skipToContent')}
        </a>

        <DashboardNavbar
          sidebarId={sidebarId}
          mobileNavOpen={mobileNavOpen}
          onToggleMobileNav={toggleMobile}
        />

        <DashboardSidebar
          id={sidebarId}
          mobileOpen={mobileNavOpen}
          onCloseMobile={closeMobile}
          account={account}
          onSignOut={onSignOut}
          signingOut={signingOut}
          showChangeWorkScope={canChangeWorkScope}
          onChangeWorkScope={reopenChoice}
        />

        <div className="pt-[calc(3.5rem+env(safe-area-inset-top))] lg:pl-64">
          <main
            id="dashboard-main"
            className="mx-auto w-full max-w-6xl min-w-0 px-4 py-6 pb-[max(2rem,env(safe-area-inset-bottom))] sm:px-8 sm:py-8 lg:px-12 lg:py-12"
          >
            <Outlet />
          </main>
        </div>
      </div>
      </ClinicProvider>
    </LiveChannelProvider>
  )
}
