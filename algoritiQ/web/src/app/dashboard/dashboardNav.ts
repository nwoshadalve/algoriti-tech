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
import { effectiveLicenseType } from '@/core/clinic/clinicLicenseCache'
import {
  ActivityIcon,
  AuditIcon,
  BoardIcon,
  ConfigIcon,
  HardDriveIcon,
  HelpIcon,
  OverviewIcon,
  QueueIcon,
  StethoscopeIcon,
  KeyIcon,
  UsersIcon,
} from '@/core/ui/icons'

export type DashboardNavLink = {
  kind: 'link'
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

export type DashboardNavGroup = {
  kind: 'group'
  id: string
  labelKey: MessageKey
  icon: ComponentType<SVGProps<SVGSVGElement>>
  children: DashboardNavLink[]
  roles?: Role[]
}

export type DashboardNavEntry = DashboardNavLink | DashboardNavGroup

/** Primary dashboard navigation: top-level order and nested configuration items. */
export const dashboardNavEntries: DashboardNavEntry[] = [
  { kind: 'link', to: '/home', labelKey: 'navOverview', icon: OverviewIcon, end: true, roles: ['admin'] },
  { kind: 'link', to: '/board', labelKey: 'navBoard', icon: BoardIcon, end: true, roles: ['admin', 'receptionist'] },
  { kind: 'link', to: '/users', labelKey: 'navUsers', icon: UsersIcon, roles: ['admin'] },
  {
    kind: 'group',
    id: 'conf',
    labelKey: 'navConf',
    icon: ConfigIcon,
    roles: ['admin'],
    children: [
      {
        kind: 'link',
        to: '/config/doctor',
        labelKey: 'navDoctor',
        icon: StethoscopeIcon,
        license: 'doctor',
      },
      {
        kind: 'link',
        to: '/config/chamber',
        labelKey: 'navChamber',
        icon: KeyIcon,
        license: 'doctor',
      },
      {
        kind: 'link',
        to: '/config/queue',
        labelKey: 'navQueue',
        icon: QueueIcon,
      },
    ],
  },
  { kind: 'link', to: '/monitoring', labelKey: 'navMonitoring', icon: ActivityIcon, roles: ['admin'] },
  { kind: 'link', to: '/audit', labelKey: 'navAudit', icon: AuditIcon, roles: ['admin'] },
  { kind: 'link', to: '/backup', labelKey: 'navBackup', icon: HardDriveIcon, roles: ['admin'] },
  { kind: 'link', to: '/help', labelKey: 'navHelp', icon: HelpIcon, end: true },
]

/** Height of the top bar shown below `lg` (the sidebar replaces it above). */
export const dashboardTopBarHeightClass = 'h-14'

function visibleLink(
  item: DashboardNavLink,
  licenseType: LicenseType | null | undefined,
  role: Role,
): boolean {
  if (item.roles && !item.roles.includes(role)) return false
  if (!item.license) return true

  const effective = effectiveLicenseType(licenseType)
  if (effective === undefined) {
    return item.license === 'doctor'
  }
  return item.license === effective
}

export function visibleDashboardNavEntries(
  licenseType: LicenseType | null | undefined,
  role: Role | undefined,
): DashboardNavEntry[] {
  const who = role ?? 'admin'
  const out: DashboardNavEntry[] = []

  for (const entry of dashboardNavEntries) {
    if (entry.kind === 'link') {
      if (entry.roles && !entry.roles.includes(who)) continue
      if (!visibleLink(entry, licenseType, who)) continue
      out.push(entry)
      continue
    }

    if (entry.roles && !entry.roles.includes(who)) continue
    const children = entry.children.filter((child) => visibleLink(child, licenseType, who))
    if (children.length === 0) continue
    out.push({ ...entry, children })
  }

  return out
}

/** Flat links for tests and helpers that only need destinations. */
export function visibleDashboardNavLinks(
  licenseType: LicenseType | null | undefined,
  role: Role | undefined,
): DashboardNavLink[] {
  const links: DashboardNavLink[] = []
  for (const entry of visibleDashboardNavEntries(licenseType, role)) {
    if (entry.kind === 'link') links.push(entry)
    else links.push(...entry.children)
  }
  return links
}
