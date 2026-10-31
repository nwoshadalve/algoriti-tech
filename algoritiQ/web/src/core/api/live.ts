/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { resolveApiBase } from '@/core/config'

/** Live WebSocket frame types from the tablet API. */
export type LiveFrame =
  | { type: 'hello'; eventSequence: number; serverTime: string }
  | { type: 'snapshot'; eventSequence: number; payload: Record<string, unknown> }
  | { type: 'event'; eventSequence: number; name: string; payload: Record<string, unknown> }
  | { type: 'ping'; eventSequence: number }

export type LiveConnectionState = 'idle' | 'connecting' | 'connected' | 'offline'

/**
 * Builds `wss://…/api/v1/ws/live?token=…` from the same origin rules as REST.
 * Browsers cannot send `Authorization` on a WebSocket handshake, so the session
 * token travels in the query string on the clinic LAN only.
 */
export function resolveLiveWebSocketUrl(token: string): string {
  const rest = resolveApiBase().replace(/\/$/, '')
  const wsPath = `${rest}/ws/live`

  if (rest.startsWith('http://') || rest.startsWith('https://')) {
    const url = new URL(wsPath)
    url.protocol = url.protocol === 'https:' ? 'wss:' : 'ws:'
    url.search = ''
    url.searchParams.set('token', token)
    return url.toString()
  }

  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  return `${protocol}//${window.location.host}${wsPath}?token=${encodeURIComponent(token)}`
}

export function parseLiveFrame(raw: string): LiveFrame | null {
  try {
    const data = JSON.parse(raw) as LiveFrame
    if (typeof data !== 'object' || data === null || !('type' in data)) return null
    return data
  } catch {
    return null
  }
}

export function pongFrame(): string {
  return JSON.stringify({ type: 'pong' })
}
