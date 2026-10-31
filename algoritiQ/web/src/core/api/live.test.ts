/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { parseLiveFrame, resolveLiveWebSocketUrl } from '@/core/api/live'

describe('resolveLiveWebSocketUrl', () => {
  it('should build wss url with token query on https api base', () => {
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
