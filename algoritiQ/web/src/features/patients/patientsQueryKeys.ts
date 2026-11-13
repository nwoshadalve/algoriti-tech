/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
export const patientsQueryKeys = {
  all: ['patients'] as const,
  list: (filters: {
    search: string
    gender: string
    sort: string
    ascending: boolean
  }) => [...patientsQueryKeys.all, 'list', filters] as const,
  chambers: ['patients', 'chambers'] as const,
  /** Every registered patient: no search or filter applies. */
  registeredTotal: ['patients', 'registered-total'] as const,
}
