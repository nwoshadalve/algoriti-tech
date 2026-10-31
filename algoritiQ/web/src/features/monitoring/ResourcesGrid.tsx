/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Monitoring } from '@/core/api/monitoring'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { CpuIcon, HardDriveIcon, MemoryIcon } from '@/core/ui/icons'
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

/** CPU, memory and storage of the tablet. */
export function ResourcesGrid({ resources }: { resources: Monitoring['resources'] }) {
  const { t } = useLocale()
  const { cpu, ram, storage } = resources
  const percent = (value: number | undefined) =>
    value === undefined ? '—' : `${percentText.format(value)}%`

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
    </ul>
  )
}
