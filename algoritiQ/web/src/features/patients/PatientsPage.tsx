/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useInfiniteQuery, useQuery, useQueryClient } from '@tanstack/react-query'
import { useContext, useEffect, useState } from 'react'
import { listChambers } from '@/core/api/chambers'
import { listPatients } from '@/core/api/patients'
import type { PatientGender, PatientSort, PatientSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { PersonAddIcon, SearchIcon, UsersIcon } from '@/core/ui/icons'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SelectField } from '@/core/ui/SelectField'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { PatientAddModal } from '@/features/patients/PatientAddModal'
import { PatientEditModal } from '@/features/patients/PatientEditModal'
import { usePatientDrafts } from '@/features/patients/patientDrafts'
import { patientsQueryKeys } from '@/features/patients/patientsQueryKeys'
import { WorkScopeContext } from '@/features/work/workScopeContext'
import { PatientsTable } from '@/features/patients/PatientsTable'

const PAGE_SIZE = 30
const SEARCH_DEBOUNCE_MS = 300

type GenderFilter = PatientGender | 'unset' | ''

/** Dates and counts read best with the biggest or newest first; names and IDs from the start. */
const biggestFirst: ReadonlySet<PatientSort> = new Set(['registered', 'visits', 'lastVisit'])

/** The patient list: search, filter and sort, add a patient, edit one. */
export function PatientsPage() {
  const { t, locale } = useLocale()
  const queryClient = useQueryClient()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const scope = useContext(WorkScopeContext)
  const { drafts } = usePatientDrafts()

  const [searchInput, setSearchInput] = useState('')
  const [search, setSearch] = useState('')
  const [gender, setGender] = useState<GenderFilter>('')
  const [sort, setSort] = useState<PatientSort>('registered')
  const [ascending, setAscending] = useState(false)
  const [adding, setAdding] = useState(false)
  const [editing, setEditing] = useState<PatientSummary | null>(null)

  useEffect(() => {
    const timer = setTimeout(() => setSearch(searchInput.trim()), SEARCH_DEBOUNCE_MS)
    return () => clearTimeout(timer)
  }, [searchInput])

  const filters = { search, gender, sort, ascending }
  const list = useInfiniteQuery({
    queryKey: patientsQueryKeys.list(filters),
    queryFn: async ({ pageParam }) => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listPatients(token, {
        search,
        gender: gender || undefined,
        sort,
        ascending,
        limit: PAGE_SIZE,
        offset: pageParam,
      })
    },
    initialPageParam: 0,
    getNextPageParam: (last, pages) => {
      const loaded = pages.reduce((sum, page) => sum + page.items.length, 0)
      return loaded < last.total ? loaded : undefined
    },
    enabled: Boolean(account),
    retry: false,
  })

  // Every patient registered: asked for on its own, so a search or filter never changes it.
  const registered = useQuery({
    queryKey: patientsQueryKeys.registeredTotal,
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      const page = await listPatients(token, { limit: 1 })
      return page.registeredTotal ?? page.total
    },
    enabled: Boolean(account),
    retry: false,
  })

  // An admin registers in any chamber; a receptionist in the one they work at.
  const isAdmin = account?.role === 'admin'
  const chamberList = useQuery({
    queryKey: patientsQueryKeys.chambers,
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return listChambers(token)
    },
    enabled: isAdmin,
    retry: false,
  })
  const scopeChamberId =
    scope?.state.status === 'ready'
      ? (scope.state.selected.deskChamberId ?? scope.state.selected.id)
      : ''
  const scopeChamberName = scope?.state.status === 'ready' ? scope.state.selected.name : ''
  const addChambers = isAdmin
    ? (chamberList.data ?? []).map((c) => ({ id: c.id, name: c.name }))
    : scopeChamberId
      ? [{ id: scopeChamberId, name: scopeChamberName }]
      : []

  if (!account) return null

  const patients = list.data?.pages.flatMap((page) => page.items) ?? []
  const total = list.data?.pages[0]?.total ?? 0
  const registeredTotal = registered.data
  const draftIds = new Set(
    Object.keys(drafts)
      .filter((key) => key.startsWith('edit:'))
      .map((key) => key.slice('edit:'.length)),
  )
  const loading = list.isPending && list.data === undefined
  const failed = list.isError && list.data === undefined
  const hasFilters = Boolean(search || gender)
  const nf = new Intl.NumberFormat(locale)

  function refresh() {
    void queryClient.invalidateQueries({ queryKey: patientsQueryKeys.all })
  }

  /** A column heading was pressed: that column, or the other way round if it already sorts. */
  function sortBy(column: PatientSort) {
    if (column === sort) {
      setAscending((current) => !current)
      return
    }
    setSort(column)
    setAscending(!biggestFirst.has(column))
  }

  function clearFilters() {
    setSearchInput('')
    setSearch('')
    setGender('')
  }

  return (
    <div className="pb-6">
      <PageHeader
        title={t('navPatients')}
        description={t('patientsIntro')}
        actions={
          <LoadingButton
            className="sm:w-auto sm:min-w-44"
            disabled={addChambers.length === 0}
            onClick={() => setAdding(true)}
          >
            <span className="inline-flex items-center justify-center gap-2">
              <PersonAddIcon width={18} height={18} />
              {t('patientsAdd')}
              {'page-new' in drafts ? ` · ${t('draftBadge')}` : ''}
            </span>
          </LoadingButton>
        }
      />

      <div className="mb-4 grid grid-cols-2 gap-3 sm:max-w-md" aria-label={t('patientsTotalLabel')}>
        <div className="flex items-center gap-3 rounded-2xl border border-brand-navy/10 bg-white px-3 py-2.5 shadow-sm dark:border-white/10 dark:bg-brand-navy-raised">
          <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-brand-coral/15 text-brand-coral-action">
            <UsersIcon width={18} height={18} />
          </span>
          <div className="min-w-0">
            <p className="truncate text-xs font-medium text-brand-navy/65 dark:text-white/65">
              {t('patientsTotalLabel')}
            </p>
            <p className="text-xl leading-tight font-bold tabular-nums" data-testid="patients-total">
              {registeredTotal === undefined ? '—' : nf.format(registeredTotal)}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-3 rounded-2xl border border-brand-navy/10 bg-white px-3 py-2.5 shadow-sm dark:border-white/10 dark:bg-brand-navy-raised">
          <span className="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-brand-navy/10 text-brand-navy dark:bg-white/10 dark:text-white">
            <SearchIcon width={18} height={18} />
          </span>
          <div className="min-w-0">
            <p className="truncate text-xs font-medium text-brand-navy/65 dark:text-white/65">
              {t('patientsShownLabel')}
            </p>
            <p className="text-xl leading-tight font-bold tabular-nums" data-testid="patients-shown">
              {loading ? '—' : nf.format(total)}
            </p>
          </div>
        </div>
      </div>

      <div className="mb-4 grid grid-cols-2 gap-3 lg:grid-cols-[minmax(0,1fr)_11rem_11rem_auto] lg:items-center">
        <div className="relative col-span-2 lg:col-span-1">
          <label htmlFor="patients-search" className="sr-only">
            {t('patientsSearch')}
          </label>
          <SearchIcon
            width={18}
            height={18}
            className="pointer-events-none absolute top-1/2 left-3 -translate-y-1/2 text-brand-navy/50 dark:text-white/50"
          />
          <input
            id="patients-search"
            type="search"
            placeholder={t('patientsSearch')}
            value={searchInput}
            onChange={(event) => setSearchInput(event.target.value)}
            className="block min-h-11 w-full rounded-lg border border-brand-navy/15 bg-white py-2 pr-3 pl-10 text-sm text-brand-navy shadow-sm outline-none placeholder:text-brand-navy/45 focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white dark:placeholder:text-white/45"
          />
        </div>
        <SelectField
          id="patients-gender"
          label={t('patientsGender')}
          hideLabel
          value={gender}
          onChange={(event) => setGender(event.target.value as GenderFilter)}
          options={[
            { value: '', label: t('patientsGenderAll') },
            { value: 'male', label: t('boardGenderMale') },
            { value: 'female', label: t('boardGenderFemale') },
            { value: 'other', label: t('boardGenderOther') },
            { value: 'unset', label: t('patientsGenderUnset') },
          ]}
        />
        <SelectField
          id="patients-sort"
          label={t('patientsSortOrder')}
          hideLabel
          value={sort}
          onChange={(event) => {
            const next = event.target.value as PatientSort
            setSort(next)
            setAscending(!biggestFirst.has(next))
          }}
          options={[
            { value: 'registered', label: t('patientsSortNewest') },
            { value: 'name', label: t('patientsSortName') },
            { value: 'id', label: t('patientsSortId') },
            { value: 'phone', label: t('patientsSortPhone') },
            { value: 'visits', label: t('patientsSortVisits') },
            { value: 'lastVisit', label: t('patientsSortLastVisit') },
          ]}
        />
        <div className="flex flex-wrap items-center gap-x-4 gap-y-2 col-span-2 lg:col-span-1">
          <button
            type="button"
            className={`${secondaryButton} !min-h-11 !px-3`}
            aria-pressed={ascending}
            onClick={() => setAscending((current) => !current)}
          >
            {t('patientsReverse')}
          </button>
          {hasFilters ? (
            <button type="button" className={`${secondaryButton} !min-h-11 !px-3`} onClick={clearFilters}>
              {t('patientsClearFilters')}
            </button>
          ) : null}
        </div>
      </div>


      {loading ? <PagePreloader label={t('loadingLabel')} /> : null}
      {failed ? (
        <NoticeBanner tone="error">
          {t('patientsLoadFailed')}
          <button type="button" className={`${secondaryButton} mt-2`} onClick={() => void list.refetch()}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      ) : null}
      {!loading && !failed && patients.length === 0 ? (
        <div className="rounded-2xl border border-brand-navy/10 bg-white px-4 py-10 text-center text-sm text-brand-navy/70 dark:border-white/10 dark:bg-brand-navy-raised dark:text-white/70">
          <p>{hasFilters ? t('patientsEmptyFiltered') : t('patientsEmpty')}</p>
          {hasFilters ? (
            <button type="button" className={`${secondaryButton} mt-4`} onClick={clearFilters}>
              {t('patientsClearFilters')}
            </button>
          ) : null}
        </div>
      ) : null}

      {patients.length > 0 ? (
        <PatientsTable
          patients={patients}
          draftIds={draftIds}
          hasMore={Boolean(list.hasNextPage)}
          loadingMore={list.isFetchingNextPage}
          moreFailed={list.isFetchNextPageError}
          onLoadMore={() => void list.fetchNextPage()}
          onEdit={setEditing}
          sort={sort}
          ascending={ascending}
          onSort={sortBy}
        />
      ) : null}

      {adding ? (
        <PatientAddModal
          chambers={addChambers}
          onClose={() => setAdding(false)}
          onSaved={() => {
            setAdding(false)
            refresh()
          }}
        />
      ) : null}
      {editing ? (
        <PatientEditModal
          patient={editing}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null)
            refresh()
          }}
        />
      ) : null}
    </div>
  )
}
