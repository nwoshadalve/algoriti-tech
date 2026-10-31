/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'

export type HealthStatus = 'ok' | 'warning' | 'failed' | 'unavailable' | 'retrying'

export type HealthResource = {
  status: HealthStatus
  /** Short code, worded by `monitoringReasons`. */
  reason?: string
  percent?: number
  usedBytes?: number
  totalBytes?: number
  /** Bluetooth `on` / `off`, or the CPU core count. */
  detail?: string
}

export type ServiceId = 'api' | 'websocket' | 'androidService' | 'printer' | 'tv'

export type HealthService = {
  id: ServiceId
  status: HealthStatus
  reason?: string
  uptimeSeconds?: number
  /** Connected live clients (websocket only). */
  clients?: number
  retryable: boolean
  retry?: { attempt: number; max: number }
}

export type Monitoring = {
  generatedAt: string
  deviceUptimeSeconds: number
  resources: {
    cpu: HealthResource
    ram: HealthResource
    storage: HealthResource
    bluetooth: HealthResource
  }
  services: HealthService[]
}

export function getMonitoring(token: string, signal?: AbortSignal): Promise<Monitoring> {
  return apiFetch<Monitoring>('/monitoring', { headers: bearer(token), signal })
}

/** Starts the retry on the tablet and returns the reading that already shows it. */
export function retryService(token: string, id: ServiceId): Promise<Monitoring> {
  return apiFetch<Monitoring>(`/monitoring/services/${id}/retry`, {
    method: 'POST',
    headers: bearer(token),
  })
}
