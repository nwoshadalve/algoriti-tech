/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { en } from '@/core/i18n/messages/en'
import type { MessageKey } from '@/core/i18n/messages/types'
import { formatBytes, formatUptime } from '@/features/monitoring/format'
import { reasonKey, serviceOkFallback, serviceProblemDetail } from '@/features/monitoring/monitoringReasons'
import type { HealthService } from '@/core/api/monitoring'
import { websocketHealth } from '@/features/monitoring/websocketHealth'

const t = (key: MessageKey, params?: Record<string, string | number>) =>
  en[key].replace(/\{(\w+)\}/g, (_, name: string) => String(params?.[name]))

describe('formatUptime', () => {
  it('should show the two largest units', () => {
    expect(formatUptime(t, 2 * 86_400 + 4 * 3_600 + 600)).toBe('2d 4h')
    expect(formatUptime(t, 5 * 3_600 + 12 * 60)).toBe('5h 12m')
    expect(formatUptime(t, 45)).toBe('45s')
  })
})

describe('formatBytes', () => {
  it('should use GB from one gigabyte and MB below', () => {
    expect(formatBytes(3.2 * 1024 ** 3)).toBe('3.2 GB')
    expect(formatBytes(512 * 1024 ** 2)).toBe('512 MB')
  })
})

describe('reasonKey', () => {
  it('should word a known code and treat an unknown one as a failed reading', () => {
    expect(en[reasonKey('printer_not_set_up')]).toBe('No printer is set up yet.')
    expect(en[reasonKey('printer_connecting')]).toContain('Trying to connect')
    expect(reasonKey('something_new')).toBe('monitorReasonReadingFailed')
  })
})

describe('serviceProblemDetail', () => {
  it('should not show a line when the printer is warning without a reason', () => {
    const service: HealthService = {
      id: 'printer',
      status: 'warning',
      retryable: false,
    }
    expect(serviceProblemDetail(service, t)).toBeNull()
    expect(serviceOkFallback(service, t, false)).toBeNull()
  })

  it('should use ready text when the printer is ok', () => {
    const service: HealthService = { id: 'printer', status: 'ok', retryable: true }
    expect(serviceProblemDetail(service, t)).toBe('Ready to print tokens.')
  })
})

describe('websocketHealth', () => {
  it('should be ok while this browser is connected', () => {
    expect(websocketHealth('connected', 0, 2, 60).status).toBe('ok')
  })

  it('should warn while the first connection is opening', () => {
    expect(websocketHealth('connecting', 0, 2, 60).status).toBe('warning')
    expect(websocketHealth('connecting', 0, 2, 60).reason).toBe('live_connecting')
  })

  it('should retry after a dropped connection', () => {
    const health = websocketHealth('offline', 3, 2, 60)

    expect(health.status).toBe('retrying')
    expect(health.retry).toEqual({ attempt: 3, max: 0 })
    expect(health.retryable).toBe(true)
  })

  it('should show the attempt while reconnecting', () => {
    expect(websocketHealth('connecting', 3, 2, 60).retry).toEqual({ attempt: 3, max: 0 })
  })
})
