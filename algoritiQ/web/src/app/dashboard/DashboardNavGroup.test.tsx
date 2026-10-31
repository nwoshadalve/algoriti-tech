/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, expect, it } from 'vitest'
import { MemoryRouter } from 'react-router-dom'
import { render } from '@testing-library/react'
import { DashboardNavGroup } from '@/app/dashboard/DashboardNavGroup'
import type { DashboardNavGroup as NavGroupConfig } from '@/app/dashboard/dashboardNav'
import { QueueIcon, StethoscopeIcon, ConfigIcon } from '@/core/ui/icons'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'

const group: NavGroupConfig = {
  kind: 'group',
  id: 'conf',
  labelKey: 'navConf',
  icon: ConfigIcon,
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
      to: '/config/queue',
      labelKey: 'navQueue',
      icon: QueueIcon,
    },
  ],
}

describe('dashboard nav group', () => {
  it('should expand nested links when the toggle is pressed', async () => {
    const user = userEvent.setup()
    render(
      <MemoryRouter initialEntries={['/home']}>
        <LocaleProvider>
          <DashboardNavGroup group={group} />
        </LocaleProvider>
      </MemoryRouter>,
    )

    const toggle = screen.getByRole('button', { name: 'Conf' })
    expect(toggle).toHaveAttribute('aria-expanded', 'false')
    expect(screen.getByRole('link', { name: 'Doctor', hidden: true })).toBeInTheDocument()

    await user.click(toggle)

    expect(toggle).toHaveAttribute('aria-expanded', 'true')
    expect(screen.getByRole('link', { name: 'Doctor' })).toBeInTheDocument()
  })

  it('should start expanded when a child route is active', () => {
    render(
      <MemoryRouter initialEntries={['/config/queue']}>
        <LocaleProvider>
          <DashboardNavGroup group={group} />
        </LocaleProvider>
      </MemoryRouter>,
    )

    expect(screen.getByRole('button', { name: 'Conf' })).toHaveAttribute('aria-expanded', 'true')
    expect(screen.getByRole('link', { name: 'Queue configuration' })).toHaveAttribute(
      'aria-current',
      'page',
    )
  })
})
