/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { LiveConnectionState } from '@/core/api/live'
import type { HealthService } from '@/core/api/monitoring'

/**
 * The WebSockets tile is this browser's own live connection (the tablet cannot
 * know whether a browser could reach it), plus how many clients the tablet
 * counts.
 */
export function websocketHealth(
  live: LiveConnectionState,
  attempt: number,
  clients: number | undefined,
  uptimeSeconds: number | undefined,
): HealthService {
  const base = { id: 'websocket' as const, retryable: true, clients, uptimeSeconds }
  if (live === 'connected') return { ...base, status: 'ok' }
  // `idle` is the moment before the first connection: not a failure yet.
  if (live === 'idle') return { ...base, status: 'retrying', retry: { attempt: 1, max: 0 } }
  if (live === 'connecting' && attempt > 0) {
    return { ...base, status: 'retrying', retry: { attempt, max: 0 } }
  }
  if (live === 'connecting') return { ...base, status: 'retrying', retry: { attempt: 1, max: 0 } }
  return { ...base, status: 'failed', reason: 'live_offline' }
}
