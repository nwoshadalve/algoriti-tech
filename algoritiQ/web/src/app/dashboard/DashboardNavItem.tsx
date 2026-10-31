/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { NavLink } from 'react-router-dom'
import { dashboardNavLinkClass } from '@/app/dashboard/dashboardNavLinkStyles'
import type { DashboardNavLink } from '@/app/dashboard/dashboardNav'
import { useLocale } from '@/core/i18n/LocaleProvider'

type DashboardNavItemProps = {
  item: DashboardNavLink
  nested?: boolean
  onNavigate?: () => void
}

export function DashboardNavItem({ item, nested = false, onNavigate }: DashboardNavItemProps) {
  const { t } = useLocale()
  const Icon = item.icon

  return (
    <NavLink
      to={item.to}
      end={item.end}
      onClick={onNavigate}
      className={({ isActive }) => dashboardNavLinkClass(isActive, nested)}
    >
      <Icon className={nested ? 'size-[18px] shrink-0 opacity-80' : 'shrink-0'} aria-hidden />
      <span className="min-w-0 flex-1 truncate">{t(item.labelKey)}</span>
    </NavLink>
  )
}
