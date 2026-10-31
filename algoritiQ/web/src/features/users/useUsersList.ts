/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useRef, useState } from 'react'
import { listUsers } from '@/core/api/users'
import type { ManagedUser, UsersQuery } from '@/core/api/types'
import { readSession } from '@/features/auth/session'

type Loaded = {
  /** The query (and reload count) these rows answer. */
  key: string
  users: ManagedUser[]
  total: number
  cursor: string | null
  failed: boolean
}

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

/**
 * The users table's data: one page at a time from the tablet, which searches,
 * filters and sorts. A new query starts from the first page; scrolling asks for
 * the next. Answers to an old query are dropped.
 */
export function useUsersList(query: UsersQuery, enabled = true): UsersList {
  const [reloads, setReloads] = useState(0)
  const [loaded, setLoaded] = useState<Loaded | null>(null)
  const [loadingMore, setLoadingMore] = useState(false)
  const [moreFailed, setMoreFailed] = useState(false)
  const key = `${reloads}|${JSON.stringify(query)}`
  const current = useRef({ key, query, cursor: null as string | null })

  useEffect(() => {
    const token = readSession()
    if (!token || !enabled) return
    const controller = new AbortController()
    current.current = { key, query, cursor: null }
    listUsers(token, query, null, controller.signal).then(
      (page) => {
        current.current.cursor = page.nextCursor
        setMoreFailed(false)
        setLoadingMore(false)
        setLoaded({ key, users: page.users, total: page.total, cursor: page.nextCursor, failed: false })
      },
      () => {
        if (controller.signal.aborted) return
        setLoaded({ key, users: [], total: 0, cursor: null, failed: true })
      },
    )
    return () => controller.abort()
    // `key` already holds the whole query.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key, enabled])

  const loadMore = useCallback(() => {
    const token = readSession()
    const now = current.current
    if (!token || !now.cursor || loadingMore) return
    setLoadingMore(true)
    setMoreFailed(false)
    listUsers(token, now.query, now.cursor).then(
      (page) => {
        // The query changed while this was on its way: the answer is for nothing.
        if (current.current.key !== now.key) return
        current.current.cursor = page.nextCursor
        setLoadingMore(false)
        setLoaded((previous) => {
          if (!previous || previous.key !== now.key) return previous
          const seen = new Set(previous.users.map((user) => user.id))
          return {
            ...previous,
            users: [...previous.users, ...page.users.filter((user) => !seen.has(user.id))],
            total: page.total,
            cursor: page.nextCursor,
          }
        })
      },
      () => {
        if (current.current.key !== now.key) return
        setLoadingMore(false)
        setMoreFailed(true)
      },
    )
  }, [loadingMore])

  const reload = useCallback(() => setReloads((count) => count + 1), [])

  const replace = useCallback((user: ManagedUser) => {
    setLoaded((previous) => {
      if (!previous) return previous
      const { status } = current.current.query
      const stays = !status || user.status === status
      const known = previous.users.some((row) => row.id === user.id)
      if (!known) return previous
      return {
        ...previous,
        users: stays
          ? previous.users.map((row) => (row.id === user.id ? user : row))
          : previous.users.filter((row) => row.id !== user.id),
        total: stays ? previous.total : Math.max(0, previous.total - 1),
      }
    })
  }, [])

  const ready = loaded !== null && loaded.key === key
  return {
    users: ready ? loaded.users : [],
    total: ready ? loaded.total : 0,
    loading: !ready,
    loadingMore,
    failed: ready && loaded.failed,
    moreFailed,
    hasMore: ready && loaded.cursor !== null,
    loadMore,
    reload,
    replace,
  }
}
