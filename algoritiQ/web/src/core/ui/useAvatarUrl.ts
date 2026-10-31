/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState } from 'react'
import { fetchPhoto } from '@/core/api/profile'
import { readSession } from '@/features/auth/session'

/**
 * Object URL of the signed-in person's photo, or null when there is none (or it
 * is still loading). Loaded again whenever `photoVersion` changes.
 */
export function useAvatarUrl(
  photoVersion: number,
  source: (token: string) => Promise<Blob> = fetchPhoto,
): string | null {
  const [loaded, setLoaded] = useState<{ version: number; url: string } | null>(null)

  useEffect(() => {
    if (photoVersion === 0) return
    const token = readSession()
    if (!token) return
    let cancelled = false
    let url: string | null = null
    source(token).then(
      (blob) => {
        if (cancelled) return
        url = URL.createObjectURL(blob)
        setLoaded({ version: photoVersion, url })
      },
      // No picture to show: the initial stays.
      () => undefined,
    )
    return () => {
      cancelled = true
      if (url) URL.revokeObjectURL(url)
    }
    // `source` is a stable module function at every call site.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [photoVersion])

  return photoVersion !== 0 && loaded?.version === photoVersion ? loaded.url : null
}
