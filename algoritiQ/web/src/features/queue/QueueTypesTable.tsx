/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { QueueTypeConfig } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { BanIcon, CheckCircleIcon, PencilIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { formatQueueSerial } from '@/features/queue/formatQueueSerial'

type QueueTypesTableProps = {
  types: QueueTypeConfig[]
  togglingId: string
  actionsDisabled?: boolean
  onEdit: (type: QueueTypeConfig) => void
  onToggleEnabled: (type: QueueTypeConfig) => void
}

const cell =
  'px-4 py-3 text-sm max-md:flex max-md:items-center max-md:justify-between max-md:gap-4 max-md:px-0 max-md:py-1.5'

/** Queue types for the selected chamber: names, range, status, and row actions. */
export function QueueTypesTable({
  types,
  togglingId,
  actionsDisabled = false,
  onEdit,
  onToggleEnabled,
}: QueueTypesTableProps) {
  const { t, locale } = useLocale()

  if (types.length === 0) {
    return <p className="px-4 pb-6 text-sm text-brand-navy/70 dark:text-white/70">{t('queueTypesEmpty')}</p>
  }

  return (
    <div className="overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm max-md:border-0 max-md:bg-transparent max-md:shadow-none dark:border-white/10 dark:bg-brand-navy-raised">
      <table className="w-full border-collapse text-left" aria-label={t('queueTableLabel')}>
        <thead className="max-md:sr-only">
          <tr className="border-b border-brand-navy/10 bg-brand-mist/60 dark:border-white/10 dark:bg-white/5">
            <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
              {t('queueColName')}
            </th>
            <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
              {t('queueColRange')}
            </th>
            <th scope="col" className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
              {t('usersColStatus')}
            </th>
            <th scope="col" className="px-4 py-3 text-right text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
              {t('usersColActions')}
            </th>
          </tr>
        </thead>
        <tbody className="max-md:block max-md:space-y-3 max-md:p-3">
          {types.map((type) => {
            const label = locale === 'bn' ? type.bengaliName : type.englishName
            const alt = locale === 'bn' ? type.englishName : type.bengaliName
            return (
              <tr
                key={type.id}
                className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:rounded-2xl max-md:border max-md:p-4 dark:border-white/10"
              >
                <th scope="row" className={`${cell} font-semibold max-md:pb-2`}>
                  <div className="min-w-0">
                    <p className="truncate">{label}</p>
                    <p className="truncate text-xs font-normal text-brand-navy/65 dark:text-white/65">{alt}</p>
                  </div>
                </th>
                <td className={`${cell} tabular-nums`}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('queueColRange')}</span>
                  <span>
                    {formatQueueSerial(type.startNumber, locale)}–{formatQueueSerial(type.endNumber, locale)}
                  </span>
                </td>
                <td className={cell}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('usersColStatus')}</span>
                  <span
                    className={[
                      'inline-flex rounded-full px-2.5 py-1 text-xs font-medium',
                      type.enabled
                        ? 'bg-emerald-100 text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-100'
                        : 'bg-brand-navy/10 text-brand-navy/70 dark:bg-white/10 dark:text-white/70',
                    ].join(' ')}
                  >
                    {type.enabled ? t('queueStatusEnabled') : t('queueStatusDisabled')}
                  </span>
                </td>
                <td className={`${cell} md:text-right max-md:justify-end max-md:pt-3`}>
                  <div className="flex flex-wrap items-center gap-2 md:justify-end">
                    <IconButton
                      label={t('queueTypeEdit')}
                      ariaLabel={`${t('queueTypeEdit')}: ${label}`}
                      icon={PencilIcon}
                      labelOnSmall
                      disabled={actionsDisabled}
                      onClick={() => onEdit(type)}
                    />
                    {type.enabled ? (
                      <IconButton
                        label={t('queueTypeDisable')}
                        ariaLabel={`${t('queueTypeDisable')}: ${label}`}
                        icon={BanIcon}
                        tone="danger"
                        labelOnSmall
                        disabled={actionsDisabled || togglingId === type.id}
                        onClick={() => onToggleEnabled(type)}
                      />
                    ) : (
                      <IconButton
                        label={t('queueTypeEnable')}
                        ariaLabel={`${t('queueTypeEnable')}: ${label}`}
                        icon={CheckCircleIcon}
                        labelOnSmall
                        disabled={actionsDisabled || togglingId === type.id}
                        onClick={() => onToggleEnabled(type)}
                      />
                    )}
                  </div>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}
