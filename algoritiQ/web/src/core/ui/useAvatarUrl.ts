/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery } from '@tanstack/react-query'
import { useEffect, useState } from 'react'
import { fetchPhoto } from '@/core/api/profile'
import { avatarQueryKeys } from '@/core/query/avatarQueryKeys'
import {
  acquireAvatarObjectUrl,
  releaseAvatarObjectUrl,
} from '@/core/ui/avatarObjectUrlCache'
import { readSession } from '@/features/auth/session'

export type PhotoSource = (token: string, photoVersion: number) => Promise<Blob>

/**
 * Object URL of a person's photo, or null when there is none (or it is still loading).
 * Blobs live in TanStack Query; object URLs are ref-counted so route changes stay stable.
 */
export function useAvatarUrl(
  photoVersion: number,
  source: PhotoSource = fetchPhoto,
  scope = 'profile',
): string | null {
  const cacheKey = `${scope}:${photoVersion}`
  const [url, setUrl] = useState<string | null>(null)

  const blobQuery = useQuery({
    queryKey: avatarQueryKeys.blob(scope, photoVersion),
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return source(token, photoVersion)
    },
    enabled: photoVersion > 0,
    retry: false,
    refetchOnMount: (query) => query.state.status === 'error',
  })

  useEffect(() => {
    if (photoVersion === 0 || !blobQuery.data) {
      setUrl(null)
      return
    }
    const objectUrl = acquireAvatarObjectUrl(cacheKey, blobQuery.data)
    setUrl(objectUrl)
    return () => {
      releaseAvatarObjectUrl(cacheKey)
    }
  }, [photoVersion, blobQuery.data, cacheKey])

  if (photoVersion === 0) return null
  return url
}
