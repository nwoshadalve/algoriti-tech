/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { SearchIcon } from '@/core/ui/icons'
import { SelectField } from '@/core/ui/SelectField'
import type { UserSort, UsersQuery } from '@/core/api/types'

type UsersToolbarProps = {
  /** What is typed in the search box right now (the query follows after a pause). */
  search: string
  onSearch: (value: string) => void
  query: UsersQuery
  onChange: (changes: Partial<UsersQuery>) => void
}

/** Search, the role and status filters, and (on small screens, where the column headings are gone) the sort. */
export function UsersToolbar({ search, onSearch, query, onChange }: UsersToolbarProps) {
  const { t } = useLocale()

  const sortOptions: { value: UserSort; label: string }[] = [
    { value: 'name', label: t('usersColName') },
    { value: 'username', label: t('usersColUsername') },
    { value: 'role', label: t('usersColRole') },
    { value: 'status', label: t('usersColStatus') },
    { value: 'created', label: t('usersColAdded') },
  ]

  return (
    <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-[minmax(0,1fr)_11rem_11rem] xl:items-end">
      <div className="space-y-1.5 sm:col-span-2 lg:col-span-1">
        <label htmlFor="users-search" className="sr-only">
          {t('usersSearchLabel')}
        </label>
        <div className="relative">
          <SearchIcon className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-brand-navy/50 dark:text-white/50" />
          <input
            id="users-search"
            type="search"
            value={search}
            maxLength={100}
            autoComplete="off"
            spellCheck={false}
            placeholder={t('usersSearchPlaceholder')}
            onChange={(event) => onSearch(event.target.value)}
            className="block min-h-11 w-full rounded-lg border border-brand-navy/15 bg-white py-2 pr-3 pl-10 text-sm text-brand-navy shadow-sm outline-none placeholder:text-brand-navy/45 focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white dark:placeholder:text-white/45"
          />
        </div>
      </div>

      <SelectField
        id="users-filter-role"
        label={t('usersColRole')}
        hideLabel
        value={query.role}
        onChange={(event) => onChange({ role: event.target.value as UsersQuery['role'] })}
        options={[
          { value: '', label: `${t('usersColRole')}: ${t('usersFilterAll')}` },
          { value: 'admin', label: t('roleAdmin') },
          { value: 'receptionist', label: t('roleReceptionist') },
        ]}
      />
      <SelectField
        id="users-filter-status"
        label={t('usersFilterStatus')}
        hideLabel
        value={query.status}
        onChange={(event) => onChange({ status: event.target.value as UsersQuery['status'] })}
        options={[
          { value: '', label: `${t('usersFilterStatus')}: ${t('usersFilterAll')}` },
          { value: 'active', label: t('usersStatusActive') },
          { value: 'inactive', label: t('usersStatusInactive') },
        ]}
      />

      <div className="grid grid-cols-2 gap-3 sm:col-span-2 md:hidden">
        <SelectField
          id="users-sort"
          label={t('usersSortBy')}
          hideLabel
          value={query.sort}
          onChange={(event) => onChange({ sort: event.target.value as UserSort })}
          options={sortOptions.map((option) => ({
            ...option,
            label: `${t('usersSortBy')}: ${option.label}`,
          }))}
        />
        <SelectField
          id="users-sort-dir"
          label={`${t('usersSortBy')}: ${t('usersSortAsc')} / ${t('usersSortDesc')}`}
          hideLabel
          value={query.dir}
          onChange={(event) => onChange({ dir: event.target.value as UsersQuery['dir'] })}
          options={[
            { value: 'asc', label: t('usersSortAsc') },
            { value: 'desc', label: t('usersSortDesc') },
          ]}
        />
      </div>
    </div>
  )
}
