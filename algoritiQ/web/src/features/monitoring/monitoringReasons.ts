/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { HealthService } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'

const reasonKeys: Record<string, MessageKey> = {
  service_stopped: 'monitorReasonServiceStopped',
  battery_restricted: 'monitorReasonBatteryRestricted',
  printer_not_set_up: 'monitorReasonPrinterNotSetUp',
  printer_connecting: 'monitorReasonPrinterConnecting',
  printer_disconnected: 'monitorReasonPrinterDisconnected',
  tv_not_connected: 'monitorReasonTvNotConnected',
  bluetooth_off: 'monitorReasonBluetoothOff',
  bluetooth_missing: 'monitorReasonBluetoothMissing',
  bluetooth_denied: 'monitorReasonBluetoothDenied',
  cpu_high: 'monitorReasonCpuHigh',
  ram_high: 'monitorReasonRamHigh',
  storage_low: 'monitorReasonStorageLow',
  reading_failed: 'monitorReasonReadingFailed',
  live_offline: 'monitorReasonLiveOffline',
  live_connecting: 'monitorReasonLiveConnecting',
}

/** The short sentence for a reason code from the tablet; an unknown code is a failed reading. */
export function reasonKey(code: string): MessageKey {
  return reasonKeys[code] ?? 'monitorReasonReadingFailed'
}

/** Reason or healthy printer line; omit generic "Working normally." (use metrics or ok fallback). */
export function serviceProblemDetail(
  service: HealthService,
  t: (key: MessageKey) => string,
): string | null {
  if (service.reason) return t(reasonKey(service.reason))
  if (service.status === 'ok' && service.id === 'printer') return t('monitorReasonPrinterReady')
  return null
}

/** When a service is ok and has no reason or uptime/client metrics. */
export function serviceOkFallback(
  service: HealthService,
  t: (key: MessageKey) => string,
  hasMetrics: boolean,
): string | null {
  if (service.status !== 'ok' || hasMetrics || service.reason) return null
  if (service.id === 'printer') return t('monitorReasonPrinterReady')
  return t('monitorNoReason')
}
