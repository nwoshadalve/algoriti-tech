/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import type { MessageKey } from '@/core/i18n/messages/types'
import { Avatar } from '@/core/ui/Avatar'
import { ArrowUpIcon, BanIcon, CheckCircleIcon, LockIcon, PencilIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import type { ManagedUser, UserSort, UsersQuery } from '@/core/api/types'

type UsersTableProps = {
  users: ManagedUser[]
  query: UsersQuery
  onSort: (sort: UserSort) => void
  onEdit: (user: ManagedUser) => void
  onSetPassword: (user: ManagedUser) => void
  canSetPassword: (user: ManagedUser) => boolean
  canDisable: (user: ManagedUser) => boolean
  onToggle: (user: ManagedUser) => void
}

const columns: { sort: UserSort; label: MessageKey; className?: string }[] = [
  { sort: 'name', label: 'usersColName' },
  { sort: 'username', label: 'usersColUsername' },
  { sort: 'role', label: 'usersColRole' },
  { sort: 'status', label: 'usersColStatus' },
  { sort: 'created', label: 'usersColAdded' },
]

const cell =
  'px-4 py-3 text-sm max-md:flex max-md:items-center max-md:justify-between max-md:gap-4 max-md:px-0 max-md:py-1.5'

/**
 * The users as a table from `md` up. Below that the same markup stacks into
 * one card per person, and each value is labelled by its column.
 */
export function UsersTable({ users, query, onSort, onEdit, onSetPassword, canSetPassword, canDisable, onToggle }: UsersTableProps) {
  const { t, locale } = useLocale()
  const date = new Intl.DateTimeFormat(locale === 'bn' ? 'bn-BD' : 'en-GB', { dateStyle: 'medium' })

  return (
    <div className="overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm max-md:border-0 max-md:bg-transparent max-md:shadow-none dark:border-white/10 dark:bg-brand-navy-raised">
      <table className="w-full border-collapse text-left" aria-label={t('usersTableLabel')}>
        <thead className="max-md:sr-only">
          <tr className="border-b border-brand-navy/10 bg-brand-mist/60 dark:border-white/10 dark:bg-white/5">
            {columns.map((column) => {
              const active = query.sort === column.sort
              return (
                <th
                  key={column.sort}
                  scope="col"
                  aria-sort={active ? (query.dir === 'asc' ? 'ascending' : 'descending') : 'none'}
                  className="px-4 py-3 text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70"
                >
                  <button
                    type="button"
                    onClick={() => onSort(column.sort)}
                    className="inline-flex items-center gap-1.5 rounded-md uppercase focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                  >
                    {t(column.label)}
                    <ArrowUpIcon
                      className={[
                        'transition-transform',
                        active ? 'opacity-100' : 'opacity-0',
                        active && query.dir === 'desc' ? 'rotate-180' : '',
                      ].join(' ')}
                    />
                  </button>
                </th>
              )
            })}
            <th scope="col" className="px-4 py-3 text-right text-xs font-semibold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
              {t('usersColActions')}
            </th>
          </tr>
        </thead>
        <tbody className="max-md:block max-md:space-y-3">
          {users.map((user) => {
            const name = user.displayName || user.username
            return (
              <tr
                key={user.id}
                className="border-b border-brand-navy/10 md:last:border-0 max-md:block max-md:rounded-2xl max-md:border max-md:bg-white max-md:p-4 max-md:shadow-sm dark:border-white/10 max-md:dark:bg-brand-navy-raised"
              >
                <td className={`${cell} max-md:pb-2`}>
                  <div className="flex min-w-0 items-center gap-3">
                    <Avatar account={{ ...user, photoVersion: 0 }} />
                    <div className="min-w-0">
                      <p className="truncate font-semibold">
                        {name}
                      </p>
                      <p className="truncate text-xs text-brand-navy/65 dark:text-white/65">{user.email}</p>
                    </div>
                  </div>
                </td>
                <td className={cell} data-label={t('usersColUsername')}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('usersColUsername')}</span>
                  <span className="truncate">@{user.username}</span>
                </td>
                <td className={cell} data-label={t('usersColRole')}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('usersColRole')}</span>
                  <span>{t(roleLabelKey[user.role])}</span>
                </td>
                <td className={cell} data-label={t('usersColStatus')}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('usersColStatus')}</span>
                  <span
                    className={[
                      'inline-flex rounded-full px-2.5 py-1 text-xs font-medium',
                      user.status === 'active'
                        ? 'bg-emerald-100 text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-100'
                        : 'bg-brand-navy/10 text-brand-navy/70 dark:bg-white/10 dark:text-white/70',
                    ].join(' ')}
                  >
                    {user.status === 'active' ? t('usersStatusActive') : t('usersStatusInactive')}
                  </span>
                </td>
                <td className={cell} data-label={t('usersColAdded')}>
                  <span className="hidden text-brand-navy/60 max-md:inline dark:text-white/60">{t('usersColAdded')}</span>
                  <span className="text-brand-navy/80 dark:text-white/80">{date.format(new Date(user.createdAt))}</span>
                </td>
                <td className={`${cell} md:text-right max-md:justify-end max-md:pt-3`}>
                  <div className="flex flex-wrap items-center gap-2 md:justify-end">
                    <IconButton
                      label={t('usersEdit')}
                      ariaLabel={`${t('usersEdit')}: ${name}`}
                      icon={PencilIcon}
                      labelOnSmall
                      onClick={() => onEdit(user)}
                    />
                    {canSetPassword(user) ? (
                      <IconButton
                        label={t('usersPassword')}
                        ariaLabel={`${t('usersPassword')}: ${name}`}
                        icon={LockIcon}
                        labelOnSmall
                        onClick={() => onSetPassword(user)}
                      />
                    ) : null}
                    {user.status === 'active' ? (
                      canDisable(user) ? (
                        <IconButton
                          label={t('usersDisable')}
                          ariaLabel={`${t('usersDisable')}: ${name}`}
                          icon={BanIcon}
                          tone="danger"
                          labelOnSmall
                          onClick={() => onToggle(user)}
                        />
                      ) : null
                    ) : (
                      <IconButton
                        label={t('usersEnable')}
                        ariaLabel={`${t('usersEnable')}: ${name}`}
                        icon={CheckCircleIcon}
                        labelOnSmall
                        onClick={() => onToggle(user)}
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
