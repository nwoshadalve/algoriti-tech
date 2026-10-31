/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { BluetoothEnableOutcome } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'

/** Toast message after the tablet was asked to turn Bluetooth on. */
export function bluetoothOutcomeKey(outcome: BluetoothEnableOutcome): MessageKey {
  switch (outcome) {
    case 'already_on':
      return 'monitorBluetoothAlreadyOn'
    case 'dialog_shown':
      return 'monitorBluetoothDialogShown'
    case 'settings_opened':
      return 'monitorBluetoothSettingsOpened'
    case 'need_app_open':
      return 'monitorBluetoothNeedAppOpen'
    case 'missing':
      return 'monitorReasonBluetoothMissing'
    case 'denied':
      return 'monitorReasonBluetoothDenied'
  }
}
