/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Link } from 'react-router-dom'
import { ConnectionHealthIndicator } from '@/app/dashboard/ConnectionHealthIndicator'
import { dashboardTopBarHeightClass } from '@/app/dashboard/dashboardNav'
import { liveStateToHealth, useLiveChannel } from '@/core/api/LiveChannelProvider'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useAuth } from '@/features/auth/authContext'
import { dashboardHomePath } from '@/app/dashboard/dashboardHome'
import { BrandWordmark } from '@/core/ui/BrandWordmark'
import { MenuIcon } from '@/core/ui/icons'
import { PageToolbar } from '@/core/ui/PageToolbar'
import { WorkScopeContextHeader } from '@/features/work/WorkScopeContextHeader'

type DashboardNavbarProps = {
  sidebarId: string
  mobileNavOpen: boolean
  onToggleMobileNav: () => void
}

/**
 * Fixed top bar. Phones and tablets: menu button, logo and the connection dot;
 * from `md` also the theme and language switches. Desktop (`lg`+): it starts
 * beside the sidebar and shows the connection status and the switches. On phones
 * the switches sit above the user in the drawer instead.
 */
export function DashboardNavbar({
  sidebarId,
  mobileNavOpen,
  onToggleMobileNav,
}: DashboardNavbarProps) {
  const { t } = useLocale()
  const { state } = useAuth()
  const { state: liveState } = useLiveChannel()
  const home =
    state.status === 'signedIn' ? dashboardHomePath(state.account.role) : '/home'

  return (
    <header
      className={[
        'fixed inset-x-0 top-0 z-30 border-b border-brand-navy/10 bg-white/95 pt-[env(safe-area-inset-top)] backdrop-blur-sm lg:left-64 dark:border-white/10 dark:bg-brand-navy-raised/95',
        dashboardTopBarHeightClass,
      ].join(' ')}
    >
      <div className="flex h-full items-center gap-2 px-3 sm:px-5 lg:px-8">
        <button
          type="button"
          className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl text-brand-navy lg:hidden transition-colors hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:text-white dark:hover:bg-white/10"
          aria-expanded={mobileNavOpen}
          aria-controls={sidebarId}
          aria-label={mobileNavOpen ? t('navCloseMenu') : t('navOpenMenu')}
          onClick={onToggleMobileNav}
        >
          <MenuIcon />
        </button>
        <Link
          to={home}
          className="flex min-w-0 shrink items-center rounded-lg lg:hidden focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
        >
          <BrandWordmark height={28} />
        </Link>
        <div className="hidden min-w-0 flex-1 lg:block">
          <ConnectionHealthIndicator state={liveStateToHealth(liveState)} />
        </div>
        {state.status === 'signedIn' && state.account.role === 'receptionist' ? (
          <div className="min-w-0 flex-1 lg:hidden">
            <WorkScopeContextHeader compact />
          </div>
        ) : null}
        <div className="ml-auto flex shrink-0 items-center gap-3">
          <div className="lg:hidden">
            <ConnectionHealthIndicator state={liveStateToHealth(liveState)} compact />
          </div>
          <div className="hidden md:block">
            <PageToolbar />
          </div>
        </div>
      </div>
    </header>
  )
}
