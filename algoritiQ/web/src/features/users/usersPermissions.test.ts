/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import type { Account, ManagedUser, UsersContext } from '@/core/api/types'
import { canDisableUser, canSetUserPassword } from '@/features/users/usersPermissions'

const context: UsersContext = {
  licenseType: 'doctor',
  assignmentTarget: 'chamber',
  targets: [],
  onboarding: { needsAttention: false },
  firstAdminId: 'first',
}

const firstAdmin: Account = {
  id: 'first',
  username: 'owner',
  displayName: 'Owner',
  firstName: 'Owner',
  lastName: '',
  email: 'o@test',
  phone: '',
  photoVersion: 0,
  role: 'admin',
}

const otherAdmin: Account = { ...firstAdmin, id: 'second', username: 'second' }

const receptionist: ManagedUser = {
  id: 'r1',
  username: 'desk',
  displayName: 'Desk',
  firstName: 'Desk',
  lastName: '',
  email: 'd@test',
  phone: '',
  photoVersion: 0,
  role: 'receptionist',
  status: 'active',
  scopeIds: [],
  createdAt: '2026-01-01T00:00:00.000Z',
}

const adminUser: ManagedUser = { ...receptionist, id: 'second', role: 'admin', username: 'second' }

describe('canSetUserPassword', () => {
  it('should allow any admin to change a receptionist password', () => {
    expect(canSetUserPassword(otherAdmin, receptionist, context)).toBe(true)
  })

  it('should allow the first admin to change another admin password', () => {
    expect(canSetUserPassword(firstAdmin, adminUser, context)).toBe(true)
  })

  it('should not allow a later admin to change another admin password', () => {
    expect(canSetUserPassword(otherAdmin, adminUser, context)).toBe(false)
  })
})

describe('canDisableUser', () => {
  it('should not allow another admin to disable the first administrator', () => {
    expect(canDisableUser(otherAdmin, { ...adminUser, id: 'first' }, context)).toBe(false)
  })

  it('should allow the first administrator to disable another admin', () => {
    expect(canDisableUser(firstAdmin, adminUser, context)).toBe(true)
  })

  it('should allow disabling a receptionist', () => {
    expect(canDisableUser(otherAdmin, receptionist, context)).toBe(true)
  })
})
