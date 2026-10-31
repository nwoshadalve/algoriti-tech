/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type {
  ChamberQueueSettings,
  QueuePolicy,
  QueueSession,
  QueueTypeConfig,
} from '@/core/api/types'

export async function getQueueDefaults(token: string): Promise<{
  policy: QueuePolicy
  types: QueueTypeConfig[]
}> {
  return apiFetch('/queue/defaults', { headers: bearer(token) })
}

export async function saveQueueDefaults(
  token: string,
  policy: QueuePolicy,
): Promise<{ policy: QueuePolicy; types: QueueTypeConfig[] }> {
  return apiFetch('/queue/defaults', {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify({
      timeZone: policy.timeZone,
      dayBoundary: policy.dayBoundary,
      autoStart: policy.autoStart,
    }),
  })
}

export async function saveChamberQueueTypes(
  token: string,
  chamberId: string,
  types: QueueTypeConfig[],
): Promise<{
  settings: ChamberQueueSettings
  types: QueueTypeConfig[]
}> {
  return apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}`, {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify({ types }),
  })
}

/** Saves clinic-wide queue types (template only; admin UI uses chamber PATCH). */
export async function saveClinicQueueTypes(
  token: string,
  policy: QueuePolicy,
  types: QueueTypeConfig[],
): Promise<{ policy: QueuePolicy; types: QueueTypeConfig[] }> {
  return apiFetch('/queue/defaults', {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify({
      timeZone: policy.timeZone,
      dayBoundary: policy.dayBoundary,
      autoStart: policy.autoStart,
      types,
    }),
  })
}

export async function saveChamberQueuePolicy(
  token: string,
  chamberId: string,
  dayBoundary: string,
): Promise<{
  settings: ChamberQueueSettings
  effectivePolicy: QueuePolicy
}> {
  return apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}/policy`, {
    method: 'PATCH',
    headers: bearer(token),
    body: JSON.stringify({ dayBoundary }),
  })
}

export async function getChamberQueueConfig(
  token: string,
  chamberId: string,
): Promise<{
  settings: ChamberQueueSettings
  effectivePolicy: QueuePolicy
  types: QueueTypeConfig[]
  session: QueueSession | null
}> {
  return apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}`, {
    headers: bearer(token),
  })
}

export async function startQueueSession(
  token: string,
  chamberId: string,
): Promise<{ session: QueueSession | null }> {
  return apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}/session/start`, {
    method: 'POST',
    headers: bearer(token),
  })
}

export async function closeQueueSession(token: string, chamberId: string): Promise<void> {
  await apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}/session/close`, {
    method: 'POST',
    headers: bearer(token),
  })
}

export async function forceCloseQueueSession(
  token: string,
  chamberId: string,
  reason: string,
): Promise<void> {
  await apiFetch(`/queue/chambers/${encodeURIComponent(chamberId)}/session/force-close`, {
    method: 'POST',
    headers: bearer(token),
    body: JSON.stringify({ reason }),
  })
}
