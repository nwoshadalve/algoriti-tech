/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Account, ManagedUser, UsersContext } from '@/core/api/types'

/** Whether the signed-in admin may set [user]'s password from user management. */
export function canSetUserPassword(
  actor: Account,
  user: ManagedUser,
  context: UsersContext,
): boolean {
  if (user.role === 'receptionist') return true
  if (user.role === 'admin') return actor.id === context.firstAdminId
  return false
}

/** Whether [actor] may disable [user] from user management. */
export function canDisableUser(
  actor: Account,
  user: ManagedUser,
  context: UsersContext,
): boolean {
  if (user.id === context.firstAdminId && actor.id !== context.firstAdminId) {
    return false
  }
  return true
}
