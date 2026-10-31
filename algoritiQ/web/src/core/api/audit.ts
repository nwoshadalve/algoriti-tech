/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { apiFetch, bearer } from '@/core/api/client'
import type { AuditLogPage, AuditLogQuery } from '@/core/api/types'

export async function listAuditLog(
  token: string,
  query: AuditLogQuery = {},
): Promise<AuditLogPage> {
  const params = new URLSearchParams()
  if (query.offset != null) params.set('offset', String(query.offset))
  if (query.from) params.set('from', query.from)
  if (query.to) params.set('to', query.to)
  if (query.actionPrefix) params.set('actionPrefix', query.actionPrefix)
  if (query.outcome) params.set('outcome', query.outcome)
  const qs = params.toString()
  return apiFetch(`/audit${qs ? `?${qs}` : ''}`, { headers: bearer(token) })
}
