/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { visibleDashboardNavEntries, visibleDashboardNavLinks } from '@/app/dashboard/dashboardNav'

describe('dashboard navigation', () => {
  it('should group clinic setup under Conf for doctor-license admins', () => {
    const entries = visibleDashboardNavEntries('doctor', 'admin')
    const conf = entries.find((entry) => entry.kind === 'group' && entry.id === 'conf')
    expect(conf?.kind).toBe('group')
    if (conf?.kind !== 'group') return

    expect(conf.children.map((child) => child.to)).toEqual([
      '/config/doctor',
      '/config/chamber',
      '/config/queue',
    ])
  })

  it('should show only queue under Conf on a chamber license', () => {
    const entries = visibleDashboardNavEntries('chamber', 'admin')
    const conf = entries.find((entry) => entry.kind === 'group' && entry.id === 'conf')
    expect(conf?.kind).toBe('group')
    if (conf?.kind !== 'group') return

    expect(conf.children.map((child) => child.to)).toEqual(['/config/queue'])
  })

  it('should end with Help for every signed-in role', () => {
    expect(visibleDashboardNavLinks('doctor', 'admin').at(-1)?.to).toBe('/help')
    expect(visibleDashboardNavLinks('chamber', 'receptionist').at(-1)?.to).toBe('/help')
  })

  it('should keep Conf entries visible while the license type is still loading', () => {
    const entries = visibleDashboardNavEntries(undefined, 'admin')
    const conf = entries.find((entry) => entry.kind === 'group' && entry.id === 'conf')
    expect(conf?.kind).toBe('group')
    if (conf?.kind !== 'group') return

    expect(conf.children.map((child) => child.to)).toEqual([
      '/config/doctor',
      '/config/chamber',
      '/config/queue',
    ])
  })
})
