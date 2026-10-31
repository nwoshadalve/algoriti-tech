/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

export type AuditListFilters = {
  actionPrefix?: string
  outcome?: string
}

/** Paginated audit trail ([/audit]). */
export const auditQueryKeys = {
  all: ['audit'] as const,
  list: (filters: AuditListFilters) =>
    [
      ...auditQueryKeys.all,
      'list',
      filters.actionPrefix ?? '',
      filters.outcome ?? '',
    ] as const,
}
