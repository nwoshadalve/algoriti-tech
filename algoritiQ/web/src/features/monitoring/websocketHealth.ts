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
 * The WebSockets tile reflects this browser's live channel (see [LiveChannelProvider]),
 * not a separate tablet self-test. [clients] is how many sockets the tablet counts
 * in total (every tab, TV, etc.).
 */
export function websocketHealth(
  live: LiveConnectionState,
  attempt: number,
  clients: number | undefined,
  uptimeSeconds: number | undefined,
): HealthService {
  const base = { id: 'websocket' as const, retryable: true, clients, uptimeSeconds }
  if (live === 'connected') return { ...base, status: 'ok' }

  const firstTry = attempt === 0
  if (live === 'idle' || (live === 'connecting' && firstTry)) {
    return { ...base, status: 'warning', reason: 'live_connecting' }
  }
  if (live === 'connecting' || live === 'offline') {
    return { ...base, status: 'retrying', retry: { attempt: Math.max(attempt, 1), max: 0 } }
  }
  return { ...base, status: 'failed', reason: 'live_offline' }
}
