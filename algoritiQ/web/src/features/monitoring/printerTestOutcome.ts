/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { PrinterTestOutcome } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'

export function printerTestOutcomeKey(outcome: PrinterTestOutcome): MessageKey {
  switch (outcome) {
    case 'printed':
      return 'monitorPrinterTestPrinted'
    case 'not_connected':
      return 'monitorPrinterTestNotConnected'
    case 'no_details':
      return 'monitorPrinterTestNoDetails'
    default:
      return 'monitorPrinterTestFailed'
  }
}
