/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useId, useState } from 'react'
import { useLocation } from 'react-router-dom'
import { DashboardNavItem } from '@/app/dashboard/DashboardNavItem'
import type { DashboardNavGroup as NavGroupConfig } from '@/app/dashboard/dashboardNav'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { ChevronDownIcon } from '@/core/ui/icons'

type DashboardNavGroupProps = {
  group: NavGroupConfig
  onNavigate?: () => void
}

/** Collapsible sidebar section; opens when a child route is active. */
export function DashboardNavGroup({ group, onNavigate }: DashboardNavGroupProps) {
  const panelId = useId()
  const { pathname } = useLocation()
  const { t } = useLocale()
  const Icon = group.icon
  const childActive = group.children.some(
    (child) => pathname === child.to || pathname.startsWith(`${child.to}/`),
  )
  const [manualOpen, setManualOpen] = useState<boolean | null>(null)
  const open = manualOpen ?? childActive

  return (
    <div className="flex flex-col gap-0.5">
      <button
        type="button"
        id={`${panelId}-trigger`}
        aria-expanded={open}
        aria-controls={panelId}
        className={[
          'flex min-h-11 w-full cursor-pointer items-center gap-3 rounded-xl px-3 py-2.5 text-left text-sm font-medium transition-colors motion-reduce:transition-none',
          'focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none',
          childActive
            ? 'bg-brand-navy/8 text-brand-navy dark:bg-white/10 dark:text-white'
            : 'text-brand-navy/75 hover:bg-brand-navy/5 hover:text-brand-navy dark:text-white/75 dark:hover:bg-white/10 dark:hover:text-white',
        ].join(' ')}
        onClick={() => setManualOpen((value) => !(value ?? open))}
      >
        <Icon className="shrink-0" aria-hidden />
        <span className="min-w-0 flex-1 truncate">{t(group.labelKey)}</span>
        <ChevronDownIcon
          className={[
            'size-5 shrink-0 opacity-60 transition-transform duration-200 ease-out motion-reduce:transition-none',
            open ? 'rotate-180' : 'rotate-0',
          ].join(' ')}
          aria-hidden
        />
      </button>

      <div
        id={panelId}
        role="region"
        aria-labelledby={`${panelId}-trigger`}
        hidden={!open}
        className={[
          'grid transition-[grid-template-rows,opacity] duration-200 ease-out motion-reduce:transition-none',
          open ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0',
        ].join(' ')}
      >
        <ul className="flex min-h-0 flex-col gap-0.5 overflow-hidden">
          {group.children.map((child) => (
            <li key={child.to}>
              <DashboardNavItem item={child} nested onNavigate={onNavigate} />
            </li>
          ))}
        </ul>
      </div>
    </div>
  )
}
