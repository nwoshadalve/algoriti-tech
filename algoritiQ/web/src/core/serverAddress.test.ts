/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it } from 'vitest'
import { resolveApiBase } from '@/core/config'
import {
  clearServerAddress,
  parseServerAddress,
  readServerAddress,
  saveServerAddress,
} from '@/core/serverAddress'
import { resolveLiveWebSocketUrl } from '@/core/api/live'

describe('parseServerAddress', () => {
  it('should add https and the default port to a bare IP address', () => {
    expect(parseServerAddress('192.168.1.22')).toBe('https://192.168.1.22:8443')
  })

  it('should keep a typed port and drop scheme, path and spaces', () => {
    expect(parseServerAddress(' https://10.0.0.5:9000/dashboard ')).toBe('https://10.0.0.5:9000')
  })

  it('should accept the tablet name', () => {
    expect(parseServerAddress('algoritiq.local')).toBe('https://algoritiq.local:8443')
  })

  it('should reject empty, bare words and impossible IP addresses', () => {
    expect(parseServerAddress('')).toBeNull()
    expect(parseServerAddress('tablet')).toBeNull()
    expect(parseServerAddress('192.168.1.300')).toBeNull()
    expect(parseServerAddress('not an address')).toBeNull()
  })
})

describe('saved tablet address', () => {
  afterEach(() => clearServerAddress())

  it('should send REST and live calls to the saved address', () => {
    saveServerAddress('https://192.168.1.22:8443')
    expect(readServerAddress()).toBe('https://192.168.1.22:8443')
    expect(resolveApiBase()).toBe('https://192.168.1.22:8443/api/v1')
    expect(resolveLiveWebSocketUrl('abc')).toBe(
      'wss://192.168.1.22:8443/api/v1/ws/live?token=abc',
    )
  })

  it('should fall back to the page origin once cleared', () => {
    saveServerAddress('https://192.168.1.22:8443')
    clearServerAddress()
    expect(resolveApiBase()).toBe('/api/v1')
  })
})
