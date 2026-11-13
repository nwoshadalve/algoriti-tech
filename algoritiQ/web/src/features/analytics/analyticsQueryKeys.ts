/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { AnalyticsPeriod } from '@/core/api/analytics'

export const analyticsQueryKeys = {
  all: ['analytics'] as const,
  read: (period: AnalyticsPeriod, date: string, chamberId: string) =>
    [...analyticsQueryKeys.all, 'read', period, date, chamberId] as const,
}
