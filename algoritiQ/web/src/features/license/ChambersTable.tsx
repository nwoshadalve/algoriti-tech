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

const cell =
  'px-4 py-3 text-sm max-md:flex max-md:items-center max-md:justify-between max-md:gap-4 max-md:px-0 max-md:py-1.5'

/** The chambers: a table from `md` up, one labelled card each below that. */
export function ChambersTable({ chambers, onEdit, onDelete }: ChambersTableProps) {
  const { t } = useLocale()
  const onlyOne = chambers.length <= 1

  return (
    <table className="w-full border-collapse text-left" aria-label={t('chambersTableLabel')}>
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
          <th scope="col" className="px-4 py-3 text-right text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
            {t('usersColActions')}
          </th>
        </tr>
      </thead>
      <tbody className="max-md:block max-md:space-y-3 max-md:p-3">
        {chambers.map((chamber) => (
          <tr
            key={chamber.id}
            className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:rounded-2xl max-md:border max-md:p-4 dark:border-white/10"
          >
            <th scope="row" className={`${cell} font-semibold max-md:pb-2`}>
              <span className="truncate">{chamber.name}</span>
            </th>
            <td className={cell}>
              <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('chamberColAddress')}</span>
              <span className="min-w-0 text-right md:text-left">{chamber.location}</span>
            </td>
            <td className={cell}>
              <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('chamberColPhone')}</span>
              <span>{chamber.phone}</span>
            </td>
            <td className={`${cell} md:text-right max-md:justify-end max-md:pt-3`}>
              <div className="flex flex-wrap items-center gap-2 md:justify-end">
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
  )
}
