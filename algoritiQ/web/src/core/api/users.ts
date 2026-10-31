/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type {
  CreateUserInput,
  ManagedUser,
  UpdateUserInput,
  UsersContext,
  UsersPageResult,
  UsersQuery,
} from '@/core/api/types'

export async function getUsersContext(token: string): Promise<UsersContext> {
  return apiFetch<UsersContext>('/users/context', { headers: bearer(token) })
}

export const USERS_PAGE_SIZE = 20

/** One page of users: the search, filters, sort and paging are applied by the tablet. */
export async function listUsers(
  token: string,
  query: UsersQuery,
  cursor: string | null = null,
  signal?: AbortSignal,
): Promise<UsersPageResult> {
  const params = new URLSearchParams()
  if (query.search.trim()) params.set('search', query.search.trim())
  if (query.role) params.set('role', query.role)
  if (query.status) params.set('status', query.status)
  params.set('sort', query.sort)
  params.set('dir', query.dir)
  params.set('limit', String(USERS_PAGE_SIZE))
  if (cursor) params.set('cursor', cursor)
  return apiFetch<UsersPageResult>(`/users?${params.toString()}`, {
    headers: bearer(token),
    signal,
  })
}

export async function createUser(token: string, input: CreateUserInput): Promise<ManagedUser> {
  const result = await apiFetch<{ user: ManagedUser }>('/users', {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.user
}

export async function updateUser(
  token: string,
  userId: string,
  input: UpdateUserInput,
): Promise<ManagedUser> {
  const result = await apiFetch<{ user: ManagedUser }>(`/users/${userId}`, {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify(input),
  })
  return result.user
}

export async function setUserPassword(
  token: string,
  userId: string,
  password: string,
): Promise<void> {
  await apiFetch<void>(`/users/${userId}/password`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ password }),
  })
}
