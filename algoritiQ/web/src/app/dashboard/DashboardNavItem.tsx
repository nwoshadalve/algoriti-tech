/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { NavLink } from 'react-router-dom'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { DashboardNavItem as NavItemConfig } from '@/app/dashboard/dashboardNav'

type DashboardNavItemProps = {
  item: NavItemConfig
  onNavigate?: () => void
}

export function DashboardNavItem({ item, onNavigate }: DashboardNavItemProps) {
  const { t } = useLocale()
  const Icon = item.icon

  return (
    <NavLink
      to={item.to}
      end={item.end}
      onClick={onNavigate}
      className={({ isActive }) =>
        [
          'group flex min-h-11 items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition-colors',
          'focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none',
          isActive
            ? 'bg-brand-navy text-white dark:bg-white dark:text-brand-navy'
            : 'text-brand-navy/75 hover:bg-brand-navy/5 hover:text-brand-navy dark:text-white/75 dark:hover:bg-white/10 dark:hover:text-white',
        ].join(' ')
      }
    >
      <Icon className="shrink-0" />
      <span className="min-w-0 flex-1 truncate">{t(item.labelKey)}</span>
    </NavLink>
  )
}
