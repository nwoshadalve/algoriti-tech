/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Link } from 'react-router-dom'
import { DashboardNavItem } from '@/app/dashboard/DashboardNavItem'
import { dashboardHomePath } from '@/app/dashboard/dashboardHome'
import { visibleDashboardNavItems } from '@/app/dashboard/dashboardNav'
import { useClinic } from '@/core/clinic/clinicContext'
import { UserMenu } from '@/app/dashboard/UserMenu'
import type { Account } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { BrandWordmark } from '@/core/ui/BrandWordmark'
import { CloseIcon } from '@/core/ui/icons'
import { LanguageSwitcher } from '@/core/ui/LanguageSwitcher'
import { ThemeToggle } from '@/core/ui/ThemeToggle'

type DashboardSidebarProps = {
  id: string
  mobileOpen: boolean
  onCloseMobile: () => void
  account: Account | null
  onSignOut: () => void
  signingOut: boolean
  showChangeWorkScope?: boolean
  onChangeWorkScope?: () => void
}

/**
 * Full-height side navigation. Fixed on the left from `lg`; below that it slides in
 * as a drawer. The person's name, role and menu sit at the bottom; on phones the
 * theme and language switches sit just above them.
 */
export function DashboardSidebar({
  id,
  mobileOpen,
  onCloseMobile,
  account,
  onSignOut,
  signingOut,
  showChangeWorkScope,
  onChangeWorkScope,
}: DashboardSidebarProps) {
  const { t } = useLocale()
  const { licenseType } = useClinic()
  const items = visibleDashboardNavItems(licenseType ?? null, account?.role)
  const home = account ? dashboardHomePath(account.role) : '/home'

  return (
    <>
      <button
        type="button"
        className={[
          'fixed inset-0 z-40 bg-brand-navy/50 transition-opacity lg:hidden',
          mobileOpen ? 'opacity-100' : 'pointer-events-none opacity-0',
        ].join(' ')}
        aria-hidden={!mobileOpen}
        tabIndex={mobileOpen ? 0 : -1}
        aria-label={t('navCloseMenu')}
        onClick={onCloseMobile}
      />

      <aside
        id={id}
        className={[
          'fixed inset-y-0 left-0 z-50 flex h-dvh w-[min(85vw,18rem)] flex-col border-r border-brand-navy/10 bg-white transition-transform duration-200 ease-out dark:border-white/10 dark:bg-brand-navy-raised',
          'lg:w-64 lg:translate-x-0',
          mobileOpen ? 'translate-x-0' : '-translate-x-full',
        ].join(' ')}
      >
        <div className="flex h-16 shrink-0 items-center justify-between gap-2 px-5 pt-[env(safe-area-inset-top)]">
          <Link
            to={home}
            onClick={onCloseMobile}
            className="rounded-lg focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
          >
            <BrandWordmark height={32} />
          </Link>
          <button
            type="button"
            className="flex h-10 w-10 items-center justify-center rounded-xl text-brand-navy/70 hover:bg-brand-navy/5 lg:hidden dark:text-white/70 dark:hover:bg-white/10"
            aria-label={t('navCloseMenu')}
            onClick={onCloseMobile}
          >
            <CloseIcon />
          </button>
        </div>

        <nav
          aria-label={t('navPrimaryLabel')}
          className="flex flex-1 flex-col gap-1 overflow-y-auto px-3 py-3"
        >
          {items.map((item) => (
            <DashboardNavItem key={item.to} item={item} onNavigate={onCloseMobile} />
          ))}
        </nav>

        <div className="shrink-0 space-y-2 border-t border-brand-navy/10 px-3 pt-3 pb-[max(0.75rem,env(safe-area-inset-bottom))] dark:border-white/10">
          <div className="flex items-center justify-between gap-3 px-3 py-1 md:hidden">
            <ThemeToggle />
            <LanguageSwitcher />
          </div>
          {account ? (
            <UserMenu
              account={account}
              onSignOut={onSignOut}
              signingOut={signingOut}
              onNavigate={onCloseMobile}
              showChangeWorkScope={showChangeWorkScope}
              onChangeWorkScope={onChangeWorkScope}
            />
          ) : null}
        </div>
      </aside>
    </>
  )
}
