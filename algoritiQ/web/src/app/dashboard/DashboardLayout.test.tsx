/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, onTestFinished, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'owner',
  displayName: 'Rafi Ahmed',
  firstName: 'Rafi',
  lastName: 'Ahmed',
  phone: '',
  photoVersion: 0,
  email: 'owner@clinic.test',
  role: 'admin',
}

function adminExists() {
  vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
    adminRegistered: true,
    claimCodeRequired: false,
  })
}

describe('dashboard shell', () => {
  beforeEach(() => {
    adminExists()
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should show the navigation landmarks after sign-in', async () => {
    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Welcome back, Rafi' })).toBeInTheDocument()
    expect(screen.getByRole('banner')).toBeInTheDocument()
    expect(screen.getByRole('navigation', { name: 'Dashboard sections' })).toBeInTheDocument()
    expect(screen.getByRole('main')).toHaveAttribute('id', 'dashboard-main')
  })

  it('should not put a sign-out button in the navigation', async () => {
    renderAppAt('/home')
    await screen.findByRole('heading', { name: 'Welcome back, Rafi' })

    const nav = screen.getByRole('navigation', { name: 'Dashboard sections' })
    expect(within(nav).queryByRole('button', { name: /sign out/i })).toBeNull()
    expect(screen.queryByRole('button', { name: 'Sign out' })).toBeNull()
  })

  it('should route between sidebar sections', async () => {
    renderAppAt('/home')
    const user = userEvent.setup()

    await screen.findByRole('heading', { name: 'Welcome back, Rafi' })
    const nav = screen.getByRole('navigation', { name: 'Dashboard sections' })
    await user.click(within(nav).getByRole('button', { name: 'Conf' }))
    await user.click(within(nav).getByRole('link', { name: 'Queue configuration' }))

    expect(await screen.findByRole('heading', { name: 'Queue configuration' })).toBeInTheDocument()
  })

  it('should keep monitoring as a top-level link', async () => {
    renderAppAt('/home')
    const user = userEvent.setup()

    await screen.findByRole('heading', { name: 'Welcome back, Rafi' })
    const nav = screen.getByRole('navigation', { name: 'Dashboard sections' })
    await user.click(within(nav).getByRole('link', { name: 'Services monitoring' }))

    expect(await screen.findByRole('heading', { name: 'Services monitoring' })).toBeInTheDocument()
    expect(within(nav).getByRole('link', { name: 'Services monitoring' })).toHaveAttribute(
      'aria-current',
      'page',
    )
  })

  it('should still show the dashboard when the browser refuses the live connection', async () => {
    // regression: a phone browser whose CSP blocks ws(s) throws from `new WebSocket`,
    // which used to unmount the whole app and leave a blank screen.
    const original = globalThis.WebSocket
    onTestFinished(() => {
      vi.stubGlobal('WebSocket', original)
    })
    vi.stubGlobal(
      'WebSocket',
      class {
        constructor() {
          throw new DOMException('Refused to connect', 'SecurityError')
        }
      },
    )

    renderAppAt('/home')

    expect(await screen.findByRole('heading', { name: 'Welcome back, Rafi' })).toBeInTheDocument()
  })

  describe('the user at the bottom of the sidebar', () => {
    it('should show the first initial in capital, the name and the role', async () => {
      renderAppAt('/home')

      const trigger = await screen.findByRole('button', { name: 'Account menu' })

      expect(within(trigger).getByTestId('avatar')).toHaveTextContent('R')
      expect(within(trigger).getByText('Rafi Ahmed')).toBeInTheDocument()
      expect(within(trigger).getByText('Administrator')).toBeInTheDocument()
    })

    it('should open Settings and Sign out only, and close on Escape', async () => {
      renderAppAt('/home')
      const user = userEvent.setup()
      const trigger = await screen.findByRole('button', { name: 'Account menu' })

      expect(trigger).toHaveAttribute('aria-expanded', 'false')
      await user.click(trigger)

      expect(trigger).toHaveAttribute('aria-expanded', 'true')
      const panel = screen.getByLabelText('Account menu', { selector: 'div' })
      expect(within(panel).getByRole('link', { name: 'Settings' })).toHaveAttribute(
        'href',
        '/settings',
      )
      expect(within(panel).getByRole('button', { name: 'Sign out' })).toBeInTheDocument()
      expect(within(panel).queryByRole('button', { name: /theme/i })).toBeNull()
      expect(within(panel).queryByRole('group', { name: 'Language' })).toBeNull()

      await user.keyboard('{Escape}')
      expect(trigger).toHaveAttribute('aria-expanded', 'false')
      expect(trigger).toHaveFocus()
    })

    it('should close when something else is clicked', async () => {
      renderAppAt('/home')
      const user = userEvent.setup()
      const trigger = await screen.findByRole('button', { name: 'Account menu' })
      await user.click(trigger)

      await user.click(screen.getByRole('main'))

      expect(trigger).toHaveAttribute('aria-expanded', 'false')
    })

    it('should go to Settings from the menu', async () => {
      renderAppAt('/home')
      const user = userEvent.setup()
      await user.click(await screen.findByRole('button', { name: 'Account menu' }))

      await user.click(screen.getByRole('link', { name: 'Settings' }))

      expect(await screen.findByRole('heading', { name: 'Settings', level: 1 })).toBeInTheDocument()
    })

    it('should put the theme and language switches in the top bar', async () => {
      renderAppAt('/home')
      await screen.findByRole('heading', { name: 'Welcome back, Rafi' })

      const bar = screen.getByRole('banner')

      expect(within(bar).getByRole('button', { name: /theme/i })).toBeInTheDocument()
      expect(within(bar).getByRole('group', { name: 'Language' })).toBeInTheDocument()
    })

    it('should repeat the switches above the user for phones', async () => {
      renderAppAt('/home')
      await screen.findByRole('heading', { name: 'Welcome back, Rafi' })

      const sidebar = screen.getByRole('complementary')

      expect(within(sidebar).getByRole('button', { name: /theme/i })).toBeInTheDocument()
      expect(within(sidebar).getByRole('group', { name: 'Language' })).toBeInTheDocument()
    })

    it('should switch the language from the top bar', async () => {
      renderAppAt('/home')
      const user = userEvent.setup()
      await screen.findByRole('heading', { name: 'Welcome back, Rafi' })

      await user.click(within(screen.getByRole('banner')).getByRole('button', { name: 'বাংলা' }))

      expect(await screen.findByRole('heading', { name: 'স্বাগতম, Rafi' })) .toBeInTheDocument()
      localStorage.removeItem('algoritiq.locale')
    })
  })
})
