/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it, vi } from 'vitest'

describe('resolveApiBase', () => {
  afterEach(() => {
    vi.unstubAllEnvs()
    vi.resetModules()
  })

  it('should use the tablet origin in dev by default', async () => {
    vi.stubEnv('DEV', true)
    vi.stubEnv('VITE_API_BASE_PATH', '/api/v1')
    const { resolveApiBase } = await import('@/core/config')
    expect(resolveApiBase()).toBe('https://algoritiq.local:8443/api/v1')
  })

  it('should use a relative path in production', async () => {
    vi.stubEnv('DEV', false)
    vi.stubEnv('VITE_API_ORIGIN', '')
    vi.stubEnv('VITE_API_BASE_PATH', '/api/v1')
    const { resolveApiBase } = await import('@/core/config')
    expect(resolveApiBase()).toBe('/api/v1')
  })

  it('should honor an explicit origin override', async () => {
    vi.stubEnv('DEV', true)
    vi.stubEnv('VITE_API_ORIGIN', 'https://192.168.0.20:8443')
    vi.stubEnv('VITE_API_BASE_PATH', '/api/v1')
    const { resolveApiBase } = await import('@/core/config')
    expect(resolveApiBase()).toBe('https://192.168.0.20:8443/api/v1')
  })

  it('should allow the Vite proxy when origin is cleared in dev', async () => {
    vi.stubEnv('DEV', true)
    vi.stubEnv('VITE_API_ORIGIN', ' ')
    vi.stubEnv('VITE_API_BASE_PATH', '/api/v1')
    const { resolveApiBase } = await import('@/core/config')
    expect(resolveApiBase()).toBe('/api/v1')
  })
})
