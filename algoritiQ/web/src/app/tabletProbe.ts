/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { resolveApiBase } from '@/core/config'

/**
 * Whether the tablet answers its health check. `origin` is a tablet origin to
 * try (`https://host:port`); `null` tries the address the app already uses.
 */
export async function probeTablet(origin: string | null, timeoutMs = 6000): Promise<boolean> {
  const base = origin ? `${origin}/api/v1` : resolveApiBase()
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), timeoutMs)
  try {
    const response = await fetch(`${base}/health`, {
      signal: controller.signal,
      cache: 'no-store',
    })
    return response.ok
  } catch {
    return false
  } finally {
    clearTimeout(timer)
  }
}
