/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

type Entry = { blob: Blob; url: string; refs: number }

const entries = new Map<string, Entry>()

/** Reuses one object URL per cache key until the blob changes (safe across route remounts). */
export function acquireAvatarObjectUrl(key: string, blob: Blob): string {
  const hit = entries.get(key)
  if (hit?.blob === blob) {
    hit.refs += 1
    return hit.url
  }
  if (hit) {
    URL.revokeObjectURL(hit.url)
  }
  const url = URL.createObjectURL(blob)
  entries.set(key, { blob, url, refs: 1 })
  return url
}

export function releaseAvatarObjectUrl(key: string): void {
  const hit = entries.get(key)
  if (!hit) return
  hit.refs -= 1
  if (hit.refs > 0) return
  URL.revokeObjectURL(hit.url)
  entries.delete(key)
}

/** Drops cached URLs for one scope when `photoVersion` changes (upload/remove). */
export function dropAvatarObjectUrls(scope: string, photoVersion?: number): void {
  for (const [key, hit] of entries) {
    if (!key.startsWith(`${scope}:`)) continue
    if (photoVersion !== undefined && !key.endsWith(`:${photoVersion}`)) continue
    URL.revokeObjectURL(hit.url)
    entries.delete(key)
  }
}
