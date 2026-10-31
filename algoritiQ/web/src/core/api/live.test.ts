/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it, vi } from 'vitest'
import { parseLiveFrame } from '@/core/api/live'

describe('resolveLiveWebSocketUrl', () => {
  afterEach(() => {
    vi.unstubAllEnvs()
    vi.resetModules()
  })

  it('should build wss url with token query on https api base', async () => {
    vi.stubEnv('VITE_API_ORIGIN', 'https://algoritiq.local:8443')
    vi.stubEnv('VITE_API_BASE_PATH', '/api/v1')
    const { resolveLiveWebSocketUrl } = await import('@/core/api/live')
    const url = resolveLiveWebSocketUrl('abc')
    expect(url).toMatch(/^wss:\/\//)
    expect(url).toContain('/api/v1/ws/live')
    expect(url).toContain('token=abc')
  })
})

describe('parseLiveFrame', () => {
  it('should parse hello frames', () => {
    const frame = parseLiveFrame(
      JSON.stringify({ type: 'hello', eventSequence: 0, serverTime: '2026-01-01T00:00:00Z' }),
    )
    expect(frame?.type).toBe('hello')
  })

  it('should ignore invalid json', () => {
    expect(parseLiveFrame('{')).toBeNull()
  })
})
