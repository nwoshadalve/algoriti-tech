/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery, useQueryClient } from '@tanstack/react-query'
import { useCallback, useEffect, useMemo, useState } from 'react'
import { searchSessionTokensCompat } from '@/core/api/queueDesk'
import type { SessionTokenQuery, TokenSort, TokenStatus } from '@/core/api/types'
import { readSession } from '@/features/auth/session'
import {
  defaultSessionTokenQuery,
  queueDeskQueryKeys,
  sessionTokensListKey,
} from '@/features/board/queueDeskQueryKeys'

const PAGE_SIZE = 30
const SEARCH_DEBOUNCE_MS = 300

export function useQueueDeskSessionTable(chamberId: string, sessionOpen: boolean) {
  const queryClient = useQueryClient()
  const [searchInput, setSearchInput] = useState('')
  const [debouncedSearch, setDebouncedSearch] = useState('')
  const [status, setStatus] = useState<TokenStatus | null>(null)
  const [queueTypeId, setQueueTypeId] = useState<string | null>(null)
  const [notPrintedOnly, setNotPrintedOnly] = useState(false)
  const [sort, setSort] = useState<TokenSort>(defaultSessionTokenQuery.sort ?? 'issued')
  const [ascending, setAscending] = useState(defaultSessionTokenQuery.ascending ?? false)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(searchInput.trim()), SEARCH_DEBOUNCE_MS)
    return () => clearTimeout(timer)
  }, [searchInput])

  const listQuery = useMemo(
    (): Omit<SessionTokenQuery, 'offset' | 'limit'> => ({
      search: debouncedSearch,
      status: status ?? undefined,
      queueTypeId: queueTypeId ?? undefined,
      notPrintedOnly,
      sort,
      ascending,
    }),
    [ascending, debouncedSearch, notPrintedOnly, queueTypeId, sort, status],
  )

  const authToken = readSession()
  const enabled = Boolean(authToken && chamberId && sessionOpen)

  const tokensQuery = useInfiniteQuery({
    queryKey: sessionTokensListKey(chamberId, listQuery),
    queryFn: ({ pageParam }) =>
      searchSessionTokensCompat(authToken!, chamberId, {
        ...listQuery,
        limit: PAGE_SIZE,
        offset: pageParam,
      }),
    initialPageParam: 0,
    getNextPageParam: (lastPage, allPages) => {
      const loaded = allPages.reduce((sum, page) => sum + page.items.length, 0)
      return loaded < lastPage.total ? loaded : undefined
    },
    enabled,
  })

  const tokens = useMemo(
    () => tokensQuery.data?.pages.flatMap((page) => page.items) ?? [],
    [tokensQuery.data],
  )
  const total = tokensQuery.data?.pages[0]?.total ?? 0
  const counts = tokensQuery.data?.pages[0]?.counts ?? {}
  const hasFilters =
    debouncedSearch.length > 0 || status != null || queueTypeId != null || notPrintedOnly

  const refreshTable = useCallback(() => {
    void queryClient.invalidateQueries({
      queryKey: sessionTokensListKey(chamberId, listQuery),
    })
  }, [chamberId, listQuery, queryClient])

  const clearFilters = useCallback(() => {
    setSearchInput('')
    setDebouncedSearch('')
    setStatus(null)
    setQueueTypeId(null)
    setNotPrintedOnly(false)
  }, [])

  const toggleSort = useCallback(
    (column: TokenSort) => {
      if (sort === column) {
        setAscending((value) => !value)
        return
      }
      setSort(column)
      setAscending(true)
    },
    [sort],
  )

  return {
    searchInput,
    setSearchInput,
    status,
    setStatus,
    queueTypeId,
    setQueueTypeId,
    notPrintedOnly,
    setNotPrintedOnly: () => setNotPrintedOnly((value) => !value),
    sort,
    ascending,
    toggleSort,
    tokens,
    total,
    counts,
    hasFilters,
    clearFilters,
    refreshTable,
    isLoading: tokensQuery.isLoading,
    isFetching: tokensQuery.isFetching,
    isError: tokensQuery.isError,
    error: tokensQuery.error,
    loadMore: () => void tokensQuery.fetchNextPage(),
    hasMore: tokensQuery.hasNextPage ?? false,
    isLoadingMore: tokensQuery.isFetchingNextPage,
    listQuery,
  }
}

/** Invalidate snapshot and every token list for a chamber after a desk action. */
export function invalidateQueueDeskBoard(queryClient: ReturnType<typeof useQueryClient>, chamberId: string) {
  void queryClient.invalidateQueries({ queryKey: queueDeskQueryKeys.snapshot(chamberId) })
  void queryClient.invalidateQueries({ queryKey: [...queueDeskQueryKeys.all, 'tokens', chamberId] })
}
