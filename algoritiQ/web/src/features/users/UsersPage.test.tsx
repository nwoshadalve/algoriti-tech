/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi, type MockInstance } from 'vitest'
import * as authApi from '@/core/api/auth'
import { ApiError } from '@/core/api/client'
import * as setupApi from '@/core/api/setup'
import * as usersApi from '@/core/api/users'
import * as workScopeApi from '@/core/api/workScope'
import type { Account, ManagedUser, UsersContext, UsersPageResult } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { queryClient } from '@/core/query/queryClient'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'owner',
  displayName: 'The Owner',
  firstName: 'The',
  lastName: 'Owner',
  phone: '',
  photoVersion: 0,
  email: 'owner@clinic.test',
  role: 'admin',
}

const context: UsersContext = {
  licenseType: 'doctor',
  assignmentTarget: 'chamber',
  targets: [{ id: 'c1', name: 'Main chamber' }],
  onboarding: { needsAttention: true },
  firstAdminId: 'a1',
}

function person(over: Partial<ManagedUser> & Pick<ManagedUser, 'id' | 'username'>): ManagedUser {
  return {
    displayName: over.username,
    firstName: over.username,
    lastName: 'Person',
    email: `${over.username}@clinic.test`,
    phone: '',
    photoVersion: 0,
    role: 'receptionist',
    status: 'active',
    scopeIds: [],
    createdAt: '2026-10-01T08:00:00.000Z',
    ...over,
  }
}

const ownerRow = person({ id: 'a1', username: 'owner', displayName: 'The Owner', role: 'admin' })
const desk = person({ id: 'r1', username: 'desk', displayName: 'Desk Staff' })

const page = (users: ManagedUser[], nextCursor: string | null = null, total = users.length): UsersPageResult => ({
  users,
  total,
  nextCursor,
})

class FakeObserver {
  static last: FakeObserver | null = null
  callback: (entries: { isIntersecting: boolean }[]) => void
  constructor(callback: (entries: { isIntersecting: boolean }[]) => void) {
    this.callback = callback
    FakeObserver.last = this
  }
  observe() {}
  disconnect() {}
  unobserve() {}
  reach() {
    this.callback([{ isIntersecting: true }])
  }
}

describe('users page', () => {
  let list: MockInstance<typeof usersApi.listUsers>

  beforeEach(() => {
    queryClient.clear()
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
    vi.spyOn(usersApi, 'getUsersContext').mockResolvedValue(context)
    list = vi.spyOn(usersApi, 'listUsers').mockResolvedValue(page([ownerRow, desk]))
    FakeObserver.last = null
    vi.stubGlobal('IntersectionObserver', FakeObserver)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  async function open() {
    renderAppAt('/users')
    await screen.findByRole('table', { name: 'Users' })
    return userEvent.setup()
  }

  const lastQuery = () => list.mock.calls.at(-1)![1]
  const lastCursor = () => list.mock.calls.at(-1)![2]

  describe('the table', () => {
    it('should list everyone with role, status and the total', async () => {
      await open()

      const table = screen.getByRole('table', { name: 'Users' })
      expect(within(table).getByText('Desk Staff')).toBeInTheDocument()
      expect(within(table).getByText('@desk')).toBeInTheDocument()
      expect(within(table).getAllByText('Receptionist').length).toBeGreaterThan(0)
      expect(within(table).getAllByText('Administrator').length).toBeGreaterThan(0)
      expect(screen.getByText('Showing 2 of 2')).toBeInTheDocument()
      expect(screen.getByText('Finish setting up your team')).toBeInTheDocument()
    })

    it('should use icon buttons named for the person, with a tooltip on hover', async () => {
      const user = await open()

      const edit = screen.getByRole('button', { name: 'Edit: Desk Staff' })
      await user.hover(edit)

      expect(await screen.findByRole('tooltip', { hidden: true })).toHaveTextContent('Edit')
      await user.unhover(edit)
      await waitFor(() => expect(screen.queryByRole('tooltip', { hidden: true })).toBeNull())
    })

    it('should start with the first page sorted by name', async () => {
      await open()

      expect(lastQuery()).toEqual({ search: '', role: '', status: '', sort: 'name', dir: 'asc' })
      expect(lastCursor()).toBeNull()
    })
  })

  describe('searching, filtering and sorting (on the tablet)', () => {
    it('should search after the typing pauses, from the first page', async () => {
      const user = await open()
      const calls = list.mock.calls.length

      await user.type(screen.getByRole('searchbox', { name: 'Search users' }), 'des')

      await waitFor(() => expect(lastQuery().search).toBe('des'), { timeout: 2000 })
      // One request for the whole word, not one per letter.
      expect(list.mock.calls.length).toBe(calls + 1)
      expect(lastCursor()).toBeNull()
    })

    it('should filter by role and by status', async () => {
      const user = await open()

      await user.selectOptions(screen.getByLabelText('Role', { selector: 'select' }), 'admin')
      await waitFor(() => expect(lastQuery().role).toBe('admin'))
      await user.selectOptions(screen.getByLabelText('Status', { selector: 'select' }), 'inactive')

      await waitFor(() => expect(lastQuery()).toMatchObject({ role: 'admin', status: 'inactive' }))
    })

    it('should sort by a column, then the other way on a second click', async () => {
      const user = await open()
      const header = screen.getByRole('columnheader', { name: /^Username/ })

      await user.click(within(header).getByRole('button'))
      await waitFor(() => expect(lastQuery()).toMatchObject({ sort: 'username', dir: 'asc' }))
      expect(screen.getByRole('columnheader', { name: /^Username/ })).toHaveAttribute('aria-sort', 'ascending')

      await user.click(within(screen.getByRole('columnheader', { name: /^Username/ })).getByRole('button'))
      await waitFor(() => expect(lastQuery()).toMatchObject({ sort: 'username', dir: 'desc' }))
      expect(screen.getByRole('columnheader', { name: /^Username/ })).toHaveAttribute('aria-sort', 'descending')
    })

    it('should offer the sort as menus where the column headings are hidden', async () => {
      const user = await open()

      await user.selectOptions(screen.getByLabelText('Sort by'), 'created')

      await waitFor(() => expect(lastQuery().sort).toBe('created'))
    })

    it('should say nothing matched and clear the filters', async () => {
      const user = await open()
      list.mockResolvedValue(page([]))

      await user.selectOptions(screen.getByLabelText('Status', { selector: 'select' }), 'inactive')
      expect(await screen.findByText('No users match your search or filters.')).toBeInTheDocument()

      list.mockResolvedValue(page([ownerRow, desk]))
      await user.click(screen.getByRole('button', { name: 'Clear filters' }))

      expect(await screen.findByText('Desk Staff')).toBeInTheDocument()
      expect(screen.getByLabelText('Status', { selector: 'select' })).toHaveValue('')
    })

    it('should offer a retry when the list cannot be loaded', async () => {
      list.mockRejectedValueOnce(new ApiError('request_failed', 'x'))
      renderAppAt('/users')

      expect(await screen.findByText('The users could not be loaded.')).toBeInTheDocument()
      list.mockResolvedValue(page([desk]))
      await userEvent.setup().click(screen.getByRole('button', { name: 'Try again' }))

      expect(await screen.findByText('Desk Staff')).toBeInTheDocument()
    })
  })

  describe('paging on scroll', () => {
    it('should ask for the next page with the cursor when the end comes near', async () => {
      list.mockResolvedValueOnce(page([ownerRow], 'next-1', 2))
      await open()
      list.mockResolvedValueOnce(page([desk], null, 2))

      FakeObserver.last!.reach()

      await screen.findByText('Desk Staff', {}, { timeout: 3000 })
      expect(lastCursor()).toBe('next-1')
      expect(screen.getByText('Showing 2 of 2')).toBeInTheDocument()
    })

    it('should not show the same person twice', async () => {
      list.mockResolvedValueOnce(page([ownerRow], 'next-1', 2))
      await open()
      list.mockResolvedValueOnce(page([ownerRow, desk], null, 2))

      FakeObserver.last!.reach()

      await screen.findByText('Desk Staff', {}, { timeout: 3000 })
      const table = screen.getByRole('table', { name: 'Users' })
      expect(within(table).getAllByText('The Owner')).toHaveLength(1)
    })

    it('should start over from the first page when the search changes', async () => {
      list.mockResolvedValueOnce(page([ownerRow], 'next-1', 2))
      const user = await open()

      await user.type(screen.getByRole('searchbox', { name: 'Search users' }), 'x')

      await waitFor(() => expect(lastQuery().search).toBe('x'))
      expect(lastCursor()).toBeNull()
    })

    it('should say so and offer a retry when the next page fails', async () => {
      list.mockResolvedValueOnce(page([ownerRow], 'next-1', 2))
      await open()
      list.mockRejectedValueOnce(new ApiError('request_failed', 'x'))

      FakeObserver.last!.reach()

      const retry = await screen.findByRole('button', { name: 'Try again' })
      list.mockResolvedValueOnce(page([desk]))
      await userEvent.setup().click(retry)
      expect(await screen.findByText('Desk Staff', {}, { timeout: 3000 })).toBeInTheDocument()
    })

    it('should show a Load more button where scrolling cannot load by itself', async () => {
      vi.stubGlobal('IntersectionObserver', undefined)
      list.mockResolvedValueOnce(page([ownerRow], 'next-1', 2))
      const user = await open()
      list.mockResolvedValueOnce(page([desk]))

      await user.click(screen.getByRole('button', { name: 'Load more' }))

      expect(await screen.findByText('Desk Staff', {}, { timeout: 3000 })).toBeInTheDocument()
    })
  })

  describe('adding a user (popup)', () => {
    async function openCreate(user: ReturnType<typeof userEvent.setup>) {
      await user.click(screen.getByRole('button', { name: 'Add user' }))
      return screen.findByRole('dialog', { name: 'Add a user' })
    }

    async function fill(dialog: HTMLElement, user: ReturnType<typeof userEvent.setup>, name = 'newdesk') {
      await user.type(within(dialog).getByLabelText('First name'), 'New')
      await user.type(within(dialog).getByLabelText('Last name'), 'Desk')
      await user.type(within(dialog).getByLabelText('Email'), `${name}@clinic.test`)
      await user.type(within(dialog).getByLabelText('Username'), name)
      await user.type(within(dialog).getByLabelText('Password'), 'long-passphrase')
      await user.type(within(dialog).getByLabelText('Confirm password'), 'long-passphrase')
    }

    it('should create a receptionist with chambers, then reload the list', async () => {
      const create = vi.spyOn(usersApi, 'createUser').mockResolvedValue(desk)
      const user = await open()
      const dialog = await openCreate(user)

      await fill(dialog, user)
      await user.click(within(dialog).getByRole('checkbox', { name: 'Main chamber' }))
      const calls = list.mock.calls.length
      await user.click(within(dialog).getByRole('button', { name: 'Create account' }))

      await waitFor(() =>
        expect(create).toHaveBeenCalledWith('tok', {
          role: 'receptionist',
          username: 'newdesk',
          firstName: 'New',
          lastName: 'Desk',
          email: 'newdesk@clinic.test',
          password: 'long-passphrase',
          scopeIds: ['c1'],
        }),
      )
      expect(screen.queryByRole('dialog')).toBeNull()
      await waitFor(() => expect(list.mock.calls.length).toBe(calls + 1))
      expect(
        within(screen.getByLabelText('Notifications')).getByText('Account created.'),
      ).toBeInTheDocument()
    })

    it('should create an administrator, with no chambers to pick', async () => {
      const create = vi.spyOn(usersApi, 'createUser').mockResolvedValue({ ...desk, role: 'admin' })
      const user = await open()
      const dialog = await openCreate(user)

      expect(within(dialog).getByRole('checkbox', { name: 'Main chamber' })).toBeInTheDocument()
      await user.click(within(dialog).getByRole('radio', { name: /Administrator/ }))
      expect(within(dialog).queryByRole('checkbox', { name: 'Main chamber' })).toBeNull()
      await fill(dialog, user, 'second')
      await user.click(within(dialog).getByRole('button', { name: 'Create account' }))

      await waitFor(() =>
        expect(create).toHaveBeenCalledWith('tok', expect.objectContaining({ role: 'admin', scopeIds: [] })),
      )
    })

    it('should check the fields first and keep the popup open', async () => {
      const create = vi.spyOn(usersApi, 'createUser')
      const user = await open()
      const dialog = await openCreate(user)

      await user.click(within(dialog).getByRole('button', { name: 'Create account' }))

      expect(within(dialog).getByText('Enter your first name.')).toBeInTheDocument()
      expect(create).not.toHaveBeenCalled()
      expect(
        within(screen.getByLabelText('Notifications')).getByText('Check the highlighted fields and try again.'),
      ).toBeInTheDocument()
    })

    it('should mark the username and say why when it is taken', async () => {
      vi.spyOn(usersApi, 'createUser').mockRejectedValue(new ApiError('username_taken', 'x'))
      const user = await open()
      const dialog = await openCreate(user)
      await fill(dialog, user)

      await user.click(within(dialog).getByRole('button', { name: 'Create account' }))

      expect(
        await within(screen.getByLabelText('Notifications')).findByText(
          'Another account already uses this username.',
        ),
      ).toBeInTheDocument()
      expect(screen.getByRole('dialog')).toBeInTheDocument()
      expect(within(dialog).getAllByText('Another account already uses this username.')).toHaveLength(1)
    })

    it('should close with Cancel without saving', async () => {
      const create = vi.spyOn(usersApi, 'createUser')
      const user = await open()
      const dialog = await openCreate(user)

      await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))

      expect(screen.queryByRole('dialog')).toBeNull()
      expect(create).not.toHaveBeenCalled()
    })
  })

  describe('editing a user (popup)', () => {
    it('should open with the details and save the changes in place', async () => {
      const update = vi
        .spyOn(usersApi, 'updateUser')
        .mockResolvedValue({ ...desk, displayName: 'Dee Staff', firstName: 'Dee' })
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Edit: Desk Staff' }))
      const dialog = await screen.findByRole('dialog', { name: 'Edit user' })
      expect(within(dialog).getByLabelText('First name')).toHaveValue('desk')
      expect(within(dialog).queryByLabelText('Password')).toBeNull()
      expect(within(dialog).queryByLabelText('Username')).toBeNull()
      await user.clear(within(dialog).getByLabelText('First name'))
      await user.type(within(dialog).getByLabelText('First name'), 'Dee')
      const calls = list.mock.calls.length
      await user.click(within(dialog).getByRole('button', { name: 'Save changes' }))

      await waitFor(() =>
        expect(update).toHaveBeenCalledWith(
          'tok',
          'r1',
          expect.objectContaining({ firstName: 'Dee', scopeIds: [] }),
        ),
      )
      expect(await screen.findByText('Dee Staff')).toBeInTheDocument()
      // The row changed in place: the list was not fetched again.
      expect(list.mock.calls.length).toBe(calls)
    })

    it('should not offer chambers for an administrator', async () => {
      list.mockResolvedValue(page([ownerRow, person({ id: 'a2', username: 'second', role: 'admin' })]))
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Edit: second' }))
      const dialog = await screen.findByRole('dialog', { name: 'Edit user' })

      expect(within(dialog).queryByRole('checkbox')).toBeNull()
    })
  })

  describe('changing a password (popup)', () => {
    it('should set a receptionist password and toast success', async () => {
      const setPassword = vi.spyOn(usersApi, 'setUserPassword').mockResolvedValue(undefined)
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Change password: Desk Staff' }))
      const dialog = await screen.findByRole('dialog', { name: 'Change password' })
      await user.type(within(dialog).getByLabelText('New password'), 'long-passphrase')
      await user.type(within(dialog).getByLabelText('Confirm new password'), 'long-passphrase')
      await user.click(within(dialog).getByRole('button', { name: 'Save password' }))

      await waitFor(() =>
        expect(setPassword).toHaveBeenCalledWith('tok', 'r1', 'long-passphrase'),
      )
      expect(screen.queryByRole('dialog')).toBeNull()
      expect(
        within(screen.getByLabelText('Notifications')).getByText('Password changed.'),
      ).toBeInTheDocument()
    })

    it('should not offer change password for another admin when not the first admin', async () => {
      vi.spyOn(authApi, 'getMe').mockResolvedValue({
        ...owner,
        id: 'a2',
        username: 'second',
      })
      list.mockResolvedValue(page([person({ id: 'a3', username: 'third', role: 'admin' })]))
      await open()

      expect(
        screen.queryByRole('button', { name: 'Change password: third' }),
      ).not.toBeInTheDocument()
    })
  })

  describe('disabling and enabling', () => {
    it('should ask first, then disable', async () => {
      const update = vi.spyOn(usersApi, 'updateUser').mockResolvedValue({ ...desk, status: 'inactive' })
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Disable: Desk Staff' }))
      const dialog = await screen.findByRole('dialog', { name: 'Disable this user?' })
      expect(update).not.toHaveBeenCalled()
      await user.click(within(dialog).getByRole('button', { name: 'Disable user' }))

      await waitFor(() =>
        expect(update).toHaveBeenCalledWith('tok', 'r1', expect.objectContaining({ status: 'inactive' })),
      )
      expect(await screen.findByRole('button', { name: 'Enable: Desk Staff' })).toBeInTheDocument()
      expect(within(screen.getByLabelText('Notifications')).getByText('User disabled.')).toBeInTheDocument()
    })

    it('should do nothing when the question is cancelled', async () => {
      const update = vi.spyOn(usersApi, 'updateUser')
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Disable: Desk Staff' }))
      await user.click(
        within(await screen.findByRole('dialog')).getByRole('button', { name: 'Cancel' }),
      )

      expect(update).not.toHaveBeenCalled()
      expect(screen.getByRole('button', { name: 'Disable: Desk Staff' })).toBeInTheDocument()
    })

    it('should explain when the tablet refuses (the last administrator)', async () => {
      list.mockResolvedValue(page([ownerRow, person({ id: 'a2', username: 'second', role: 'admin' })]))
      vi.spyOn(usersApi, 'updateUser').mockRejectedValue(new ApiError('last_admin', 'x'))
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Disable: second' }))
      await user.click(
        within(await screen.findByRole('dialog')).getByRole('button', { name: 'Disable user' }),
      )

      expect(
        await within(screen.getByLabelText('Notifications')).findByText(
          'The last active administrator cannot be disabled.',
        ),
      ).toBeInTheDocument()
    })

    it('should enable a disabled user straight away', async () => {
      list.mockResolvedValue(page([ownerRow, { ...desk, status: 'inactive' }]))
      const update = vi.spyOn(usersApi, 'updateUser').mockResolvedValue(desk)
      const user = await open()

      await user.click(screen.getByRole('button', { name: 'Enable: Desk Staff' }))

      await waitFor(() =>
        expect(update).toHaveBeenCalledWith('tok', 'r1', expect.objectContaining({ status: 'active' })),
      )
      expect(await screen.findByRole('button', { name: 'Disable: Desk Staff' })).toBeInTheDocument()
    })

    it('should drop a user from the list when the status filter no longer matches', async () => {
      vi.spyOn(usersApi, 'updateUser').mockResolvedValue({ ...desk, status: 'inactive' })
      const user = await open()
      await user.selectOptions(screen.getByLabelText('Status', { selector: 'select' }), 'active')
      await waitFor(() => expect(lastQuery().status).toBe('active'))
      await screen.findByText('Desk Staff')

      await user.click(screen.getByRole('button', { name: 'Disable: Desk Staff' }))
      await user.click(
        within(await screen.findByRole('dialog')).getByRole('button', { name: 'Disable user' }),
      )

      await waitFor(() => expect(screen.queryByText('Desk Staff')).toBeNull())
    })
  })

  it('should keep non-admins out', async () => {
    vi.spyOn(authApi, 'getMe').mockResolvedValue({ ...owner, role: 'receptionist' })
    vi.spyOn(workScopeApi, 'getWorkScopes').mockResolvedValue({
      assignmentTarget: 'chamber',
      assignmentCount: 1,
      options: [{ id: 'c1', name: 'Main chamber', detail: '12 Lake Road' }],
    })
    renderAppAt('/users')

    expect(await screen.findByText('Only an administrator can manage users.')).toBeInTheDocument()
    expect(list).not.toHaveBeenCalled()
  })
})
