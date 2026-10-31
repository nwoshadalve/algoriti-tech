/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery, useQueryClient, type InfiniteData } from '@tanstack/react-query'
import { useCallback } from 'react'
import { listUsers } from '@/core/api/users'
import type { ManagedUser, UsersPageResult, UsersQuery } from '@/core/api/types'
import { readSession } from '@/features/auth/session'
import { usersQueryKeys } from '@/features/users/usersQueryKeys'

export type UsersList = {
  users: ManagedUser[]
  total: number
  /** The first page of the current query is on its way. */
  loading: boolean
  loadingMore: boolean
  /** The first page could not be loaded. */
  failed: boolean
  /** The next page could not be loaded. */
  moreFailed: boolean
  hasMore: boolean
  loadMore: () => void
  /** Starts again from the first page. */
  reload: () => void
  /** Puts one changed user into the list where it is, without losing the scroll position. */
  replace: (user: ManagedUser) => void
}

function dedupeUsers(rows: ManagedUser[]): ManagedUser[] {
  const seen = new Set<string>()
  const out: ManagedUser[] = []
  for (const user of rows) {
    if (seen.has(user.id)) continue
    seen.add(user.id)
    out.push(user)
  }
  return out
}

/**
 * The users table's data: one page at a time from the tablet, which searches,
 * filters and sorts. Cached in TanStack Query so returning to `/users` is instant.
 */
export function useUsersList(query: UsersQuery, enabled = true): UsersList {
  const queryClient = useQueryClient()
  const listKey = usersQueryKeys.list(query)

  const result = useInfiniteQuery({
    queryKey: listKey,
    queryFn: async ({ pageParam, signal }) => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listUsers(token, query, pageParam, signal)
    },
    initialPageParam: null as string | null,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
    enabled,
    retry: false,
  })

  const {
    data,
    isPending,
    isError,
    isFetchingNextPage,
    isFetchNextPageError,
    hasNextPage,
    fetchNextPage,
  } = result

  const pages = data?.pages ?? []
  const users = dedupeUsers(pages.flatMap((page) => page.users))

  const loadMore = useCallback(() => {
    if (isFetchingNextPage || !hasNextPage) return
    void fetchNextPage()
  }, [fetchNextPage, hasNextPage, isFetchingNextPage])

  const reload = useCallback(() => {
    void queryClient.invalidateQueries({ queryKey: listKey })
  }, [queryClient, listKey])

  const replace = useCallback(
    (user: ManagedUser) => {
      queryClient.setQueryData<InfiniteData<UsersPageResult>>(listKey, (previous) => {
        if (!previous) return previous
        const { status } = query
        const stays = !status || user.status === status
        const known = previous.pages.some((page) => page.users.some((row) => row.id === user.id))
        if (!known) return previous
        return {
          ...previous,
          pages: previous.pages.map((page, index) => ({
            ...page,
            users: stays
              ? page.users.map((row) => (row.id === user.id ? user : row))
              : page.users.filter((row) => row.id !== user.id),
            total:
              index === 0 && !stays ? Math.max(0, page.total - 1) : page.total,
          })),
        }
      })
    },
    [query, queryClient, listKey],
  )

  return {
    users,
    total: pages[0]?.total ?? 0,
    loading: isPending && data === undefined,
    loadingMore: isFetchingNextPage,
    failed: isError && data === undefined,
    moreFailed: isFetchNextPageError,
    hasMore: Boolean(hasNextPage),
    loadMore,
    reload,
    replace,
  }
}
