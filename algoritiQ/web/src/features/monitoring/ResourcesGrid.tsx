/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Monitoring } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { BluetoothIcon, CpuIcon, HardDriveIcon, MemoryIcon } from '@/core/ui/icons'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { ResourceCard } from '@/features/monitoring/ResourceCard'
import { formatBytes } from '@/features/monitoring/format'

const percentText = new Intl.NumberFormat(undefined, { maximumFractionDigits: 0 })

function usedOf(
  t: ReturnType<typeof useLocale>['t'],
  used: number | undefined,
  total: number | undefined,
) {
  if (used === undefined || total === undefined) return undefined
  return t('monitorUsedOf', { used: formatBytes(used), total: formatBytes(total) })
}

type ResourcesGridProps = {
  resources: Monitoring['resources']
  bluetoothBusy?: boolean
  onTurnBluetoothOn?: () => void
}

/** CPU, memory, storage and Bluetooth on the tablet. */
export function ResourcesGrid({ resources, bluetoothBusy, onTurnBluetoothOn }: ResourcesGridProps) {
  const { t } = useLocale()
  const { cpu, ram, storage, bluetooth } = resources
  const percent = (value: number | undefined) =>
    value === undefined ? '—' : `${percentText.format(value)}%`

  const bluetoothValue =
    bluetooth.detail === 'on'
      ? t('monitorBluetoothOn')
      : bluetooth.detail === 'off'
        ? t('monitorBluetoothOff')
        : '—'

  const showBluetoothAction =
    onTurnBluetoothOn &&
    bluetooth.status !== 'ok' &&
    bluetooth.reason !== 'bluetooth_missing' &&
    bluetooth.reason !== 'bluetooth_denied'

  return (
    <ul className="grid grid-cols-1 gap-3 min-[540px]:grid-cols-2 xl:grid-cols-3">
      <ResourceCard
        name={t('monitorCpu')}
        icon={CpuIcon}
        resource={cpu}
        value={percent(cpu.percent)}
        caption={cpu.detail ? t('monitorCores', { count: cpu.detail }) : undefined}
      />
      <ResourceCard
        name={t('monitorRam')}
        icon={MemoryIcon}
        resource={ram}
        value={percent(ram.percent)}
        caption={usedOf(t, ram.usedBytes, ram.totalBytes)}
      />
      <ResourceCard
        name={t('monitorStorage')}
        icon={HardDriveIcon}
        resource={storage}
        value={percent(storage.percent)}
        caption={usedOf(t, storage.usedBytes, storage.totalBytes)}
      />
      <ResourceCard
        name={t('monitorBluetooth')}
        icon={BluetoothIcon}
        resource={bluetooth}
        value={bluetoothValue}
        action={
          showBluetoothAction ? (
            <LoadingButton
              type="button"
              isLoading={bluetoothBusy}
              loadingLabel={t('monitorBluetoothTurningOn')}
              className="w-full sm:w-auto"
              onClick={onTurnBluetoothOn}
            >
              {t('monitorBluetoothTurnOn')}
            </LoadingButton>
          ) : bluetooth.reason === 'bluetooth_denied' ? (
            <p className="text-xs text-brand-navy/70 dark:text-white/70">{t('monitorReasonBluetoothDenied')}</p>
          ) : null
        }
      />
    </ul>
  )
}
