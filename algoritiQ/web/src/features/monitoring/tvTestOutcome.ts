/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { TvTestOutcome } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'

export function tvTestOutcomeKey(outcome: TvTestOutcome): MessageKey {
  switch (outcome) {
    case 'sent':
      return 'monitorTvTestSent'
    case 'not_connected':
      return 'monitorTvTestNotConnected'
    case 'no_details':
      return 'monitorTvTestNoDetails'
    default:
      return 'monitorTvTestFailed'
  }
}
