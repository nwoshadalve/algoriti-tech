/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

const reasonKeys: Record<string, MessageKey> = {
  service_stopped: 'monitorReasonServiceStopped',
  battery_restricted: 'monitorReasonBatteryRestricted',
  printer_not_set_up: 'monitorReasonPrinterNotSetUp',
  tv_not_connected: 'monitorReasonTvNotConnected',
  bluetooth_off: 'monitorReasonBluetoothOff',
  bluetooth_missing: 'monitorReasonBluetoothMissing',
  bluetooth_denied: 'monitorReasonBluetoothDenied',
  cpu_high: 'monitorReasonCpuHigh',
  ram_high: 'monitorReasonRamHigh',
  storage_low: 'monitorReasonStorageLow',
  reading_failed: 'monitorReasonReadingFailed',
  live_offline: 'monitorReasonLiveOffline',
}

/** The short sentence for a reason code from the tablet; an unknown code is a failed reading. */
export function reasonKey(code: string): MessageKey {
  return reasonKeys[code] ?? 'monitorReasonReadingFailed'
}
