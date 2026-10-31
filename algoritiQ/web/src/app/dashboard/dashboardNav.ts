/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, SVGProps } from 'react'
import type { MessageKey } from '@/core/i18n/messages/types'
import type { LicenseType, Role } from '@/core/api/types'
import {
  ActivityIcon,
  BoardIcon,
  HardDriveIcon,
  KeyIcon,
  OverviewIcon,
  StethoscopeIcon,
  UsersIcon,
} from '@/core/ui/icons'

export type DashboardNavItem = {
  to: string
  labelKey: MessageKey
  icon: ComponentType<SVGProps<SVGSVGElement>>
  /** Pass through to `<NavLink end>` for index-style routes. */
  end?: boolean
  /** Shown only for a clinic with this license. */
  license?: LicenseType
  /** When set, only these roles see the link. */
  roles?: Role[]
}

/** Primary dashboard sections: order is display order in the sidebar. */
export const dashboardNavItems: DashboardNavItem[] = [
  { to: '/home', labelKey: 'navOverview', icon: OverviewIcon, end: true, roles: ['admin'] },
  { to: '/board', labelKey: 'navBoard', icon: BoardIcon, end: true, roles: ['receptionist'] },
  { to: '/users', labelKey: 'navUsers', icon: UsersIcon, roles: ['admin'] },
  {
    to: '/doctor',
    labelKey: 'navDoctor',
    icon: StethoscopeIcon,
    license: 'doctor',
    roles: ['admin'],
  },
  {
    to: '/license',
    labelKey: 'navLicense',
    icon: KeyIcon,
    license: 'doctor',
    roles: ['admin'],
  },
  { to: '/monitoring', labelKey: 'navMonitoring', icon: ActivityIcon, roles: ['admin'] },
  { to: '/backup', labelKey: 'navBackup', icon: HardDriveIcon, roles: ['admin'] },
]

/** Height of the top bar shown below `lg` (the sidebar replaces it above). */
export const dashboardTopBarHeightClass = 'h-14'

export function visibleDashboardNavItems(
  licenseType: LicenseType | null,
  role: Role | undefined,
): DashboardNavItem[] {
  const who = role ?? 'admin'
  return dashboardNavItems.filter((item) => {
    if (item.license && item.license !== licenseType) return false
    if (item.roles && !item.roles.includes(who)) return false
    return true
  })
}
