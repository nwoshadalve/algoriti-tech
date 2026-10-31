/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Chamber } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { PencilIcon, TrashIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'

type ChambersTableProps = {
  chambers: Chamber[]
  onEdit: (chamber: Chamber) => void
  onDelete: (chamber: Chamber) => void
}

const labelClass = 'shrink-0 text-brand-navy/60 dark:text-white/60'
const valueClass = 'min-w-0 break-words text-right md:text-left'

/** Labelled field row on phones; table columns from `md` up. */
const fieldCell =
  'px-4 py-3 text-sm max-md:grid max-md:grid-cols-[minmax(0,auto)_minmax(0,1fr)] max-md:items-start max-md:gap-x-3 max-md:px-3 max-md:py-1.5'

/** The chambers: a table from `md` up, one labelled card each below that. */
export function ChambersTable({ chambers, onEdit, onDelete }: ChambersTableProps) {
  const { t } = useLocale()
  const onlyOne = chambers.length <= 1

  return (
    <div className="min-w-0 overflow-x-auto md:overflow-visible">
      <table className="w-full min-w-0 border-collapse text-left" aria-label={t('chambersTableLabel')}>
        <thead className="max-md:sr-only">
          <tr className="border-b border-brand-navy/10 bg-brand-mist/60 dark:border-white/10 dark:bg-white/5">
            {(['chamberColName', 'chamberColAddress', 'chamberColPhone'] as const).map((key) => (
              <th
                key={key}
                scope="col"
                className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70"
              >
                {t(key)}
              </th>
            ))}
            <th
              scope="col"
              className="px-4 py-3 text-right text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70"
            >
              {t('usersColActions')}
            </th>
          </tr>
        </thead>
        <tbody className="max-md:block max-md:space-y-3 max-md:p-3">
          {chambers.map((chamber) => (
            <tr
              key={chamber.id}
              className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:min-w-0 max-md:rounded-2xl max-md:border max-md:p-3 dark:border-white/10"
            >
              <th scope="row" className="px-4 py-3 text-sm font-semibold max-md:col-span-2 max-md:px-0 max-md:pb-2 max-md:block">
                <span className="min-w-0 break-words">{chamber.name}</span>
              </th>
              <td className={fieldCell}>
                <span className={`${labelClass} max-md:inline md:sr-only`}>{t('chamberColAddress')}</span>
                <span className={valueClass}>{chamber.location}</span>
              </td>
              <td className={fieldCell}>
                <span className={`${labelClass} max-md:inline md:sr-only`}>{t('chamberColPhone')}</span>
                <span className={`${valueClass} tabular-nums`}>{chamber.phone}</span>
              </td>
              <td className="px-4 py-3 text-sm max-md:px-0 max-md:pt-3 md:text-right">
                <div className="flex flex-col gap-2 max-md:w-full md:flex-row md:flex-wrap md:items-center md:justify-end md:gap-2">
                  <IconButton
                    label={t('chamberEdit')}
                    ariaLabel={`${t('chamberEdit')}: ${chamber.name}`}
                    icon={PencilIcon}
                    labelOnSmall
                    onClick={() => onEdit(chamber)}
                  />
                  <IconButton
                    label={t('chamberDelete')}
                    ariaLabel={`${t('chamberDelete')}: ${chamber.name}`}
                    icon={TrashIcon}
                    tone="danger"
                    labelOnSmall
                    disabled={onlyOne}
                    disabledReason={t('chamberLastTip')}
                    onClick={() => onDelete(chamber)}
                  />
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
