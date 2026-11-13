/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery } from '@tanstack/react-query'
import { getFeeCodes, type FeeCode } from '@/core/api/feeCodes'
import { readSession } from '@/features/auth/session'
import { feeCodesQueryKeys } from '@/features/fees/feeCodesQueryKeys'

const NO_CODES: FeeCode[] = []

/**
 * The clinic's fee codes. Empty while loading, when none are defined and when
 * the tablet cannot say (an older tablet): the desk then keeps its free fee
 * field, so patients can always be entered.
 */
export function useFeeCodes(): FeeCode[] {
  const query = useQuery({
    queryKey: feeCodesQueryKeys.all,
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('missing_session')
      return getFeeCodes(token)
    },
    staleTime: 30_000,
    retry: false,
  })
  return query.data ?? NO_CODES
}
