/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { DashboardNavGroup } from '@/app/dashboard/DashboardNavGroup'
import { DashboardNavItem } from '@/app/dashboard/DashboardNavItem'
import type { DashboardNavEntry } from '@/app/dashboard/dashboardNav'

type DashboardNavListProps = {
  entries: DashboardNavEntry[]
  onNavigate?: () => void
}

export function DashboardNavList({ entries, onNavigate }: DashboardNavListProps) {
  return (
    <>
      {entries.map((entry) =>
        entry.kind === 'group' ? (
          <DashboardNavGroup key={entry.id} group={entry} onNavigate={onNavigate} />
        ) : (
          <DashboardNavItem key={entry.to} item={entry} onNavigate={onNavigate} />
        ),
      )}
    </>
  )
}
