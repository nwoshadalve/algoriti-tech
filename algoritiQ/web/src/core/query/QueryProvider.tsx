/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClientProvider } from '@tanstack/react-query'
import { useEffect, type ReactNode } from 'react'
import { queryClient } from '@/core/query/queryClient'
import { useAuth } from '@/features/auth/authContext'
import { useQueueLiveQuerySync } from '@/features/queue/useQueueLiveQuerySync'

/** Wraps the app with TanStack Query and clears cache on sign-out. */
export function QueryProvider({ children }: { children: ReactNode }) {
  const { state } = useAuth()

  useQueueLiveQuerySync()

  useEffect(() => {
    if (state.status === 'signedOut') queryClient.clear()
  }, [state.status])

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
}
