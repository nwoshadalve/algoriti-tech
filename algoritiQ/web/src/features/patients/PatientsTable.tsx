/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { PatientSort, PatientSummary } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { canObserveScroll } from '@/core/ui/canObserveScroll'
import { ChevronDownIcon, ChevronUpDownIcon, HistoryIcon, PencilIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { ScrollSentinel } from '@/core/ui/ScrollSentinel'
import { formatDigits } from '@/features/queue/formatQueueSerial'

const genderLabelKey = {
  male: 'boardGenderMale',
  female: 'boardGenderFemale',
  other: 'boardGenderOther',
  not_stated: 'boardGenderNotStated',
} as const

type PatientsTableProps = {
  patients: PatientSummary[]
  draftIds: ReadonlySet<string>
  hasMore: boolean
  loadingMore: boolean
  moreFailed: boolean
  onLoadMore: () => void
  onEdit: (patient: PatientSummary) => void
  sort: PatientSort
  ascending: boolean
  /** A column heading was pressed: sort by it, or flip the order if it already is. */
  onSort: (column: PatientSort) => void
}

/** On phones each cell shows its small label above the value. */
function Labelled({ label }: { label: string }) {
  return (
    <span className="mb-0.5 block text-[0.7rem] font-semibold tracking-wide text-brand-navy/55 uppercase md:hidden dark:text-white/55">
      {label}
    </span>
  )
}

const cell = 'px-4 py-3 align-middle max-md:p-0'

/**
 * The patient list as a table on tablets and desktops and as cards on phones.
 * Its box has a fixed height and scrolls inside; reaching the bottom loads the next page.
 */
export function PatientsTable({
  patients,
  draftIds,
  hasMore,
  loadingMore,
  moreFailed,
  onLoadMore,
  onEdit,
  sort,
  ascending,
  onSort,
}: PatientsTableProps) {
  const { t, locale } = useLocale()
  const dateFormat = new Intl.DateTimeFormat(locale, { dateStyle: 'medium' })

  /** A column heading that sorts the list; the current column shows its direction. */
  function heading(column: PatientSort, label: string) {
    const active = sort === column
    return (
      <th scope="col" className="px-2 py-1" aria-sort={active ? (ascending ? 'ascending' : 'descending') : 'none'}>
        <button
          type="button"
          aria-label={t('patientsSortBy', { column: label })}
          className={`inline-flex min-h-10 items-center gap-1 rounded-lg px-2 text-xs font-semibold tracking-wide uppercase hover:bg-brand-navy/5 focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none dark:hover:bg-white/10 ${active ? 'text-brand-navy dark:text-white' : ''}`}
          onClick={() => onSort(column)}
        >
          {label}
          {active ? (
            <ChevronDownIcon width={14} height={14} className={ascending ? 'rotate-180' : ''} />
          ) : (
            <ChevronUpDownIcon width={14} height={14} className="opacity-50" />
          )}
        </button>
      </th>
    )
  }

  return (
    <section
      aria-label={t('patientsTableLabel')}
      className="overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised"
    >
      {/* Fixed height; no `overscroll-contain`, so a drag at the end moves the page on phones. */}
      <div className="h-[max(22rem,calc(100dvh-24rem))] overflow-auto">
        <table className="w-full min-w-0 border-collapse text-left text-sm">
          <thead className="sticky top-0 z-10 max-md:sr-only">
            <tr className="border-b border-brand-navy/10 bg-brand-mist/95 text-xs font-semibold tracking-wide text-brand-navy/65 uppercase backdrop-blur dark:border-white/10 dark:bg-brand-navy/95 dark:text-white/65">
              {heading('name', t('boardColName'))}
              {heading('id', t('patientsSortId'))}
              <th scope="col" className="px-4 py-3">{t('patientsColAge')} · {t('patientsGender')}</th>
              {heading('registered', t('patientsRegistered'))}
              {heading('visits', t('patientsVisits'))}
              {heading('lastVisit', t('patientsLastVisit'))}
              <th scope="col" className="w-16 px-4 py-3"><span className="sr-only">{t('usersColActions')}</span></th>
            </tr>
          </thead>
          <tbody className="max-md:block max-md:space-y-3 max-md:p-3">
            {patients.map((patient) => {
              const gender =
                patient.gender && patient.gender !== 'not_stated' ? t(genderLabelKey[patient.gender]) : ''
              const ageGender = [patient.ageLabel ? formatDigits(patient.ageLabel, locale) : '', gender]
                .filter(Boolean)
                .join(' · ')
              const visits = patient.visitCount ?? 0
              const initial = Array.from(patient.name.trim())[0] ?? '?'
              return (
                <tr
                  key={patient.id}
                  className="relative border-b border-brand-navy/8 transition-colors last:border-0 hover:bg-brand-mist/60 max-md:grid max-md:grid-cols-2 max-md:gap-x-4 max-md:gap-y-3 max-md:rounded-2xl max-md:border max-md:border-brand-navy/10 max-md:p-4 max-md:shadow-sm max-md:hover:bg-transparent dark:border-white/10 dark:hover:bg-white/5 max-md:dark:border-white/10"
                >
                  <td className={`${cell} max-md:col-span-2 max-md:pr-12`}>
                    <div className="flex items-center gap-3">
                      <span
                        aria-hidden="true"
                        className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-brand-coral/15 text-base font-bold text-brand-coral-action"
                      >
                        {initial}
                      </span>
                      <div className="min-w-0">
                        <p className="truncate font-semibold">{patient.name}</p>
                        <p className="truncate text-xs tabular-nums text-brand-navy/60 dark:text-white/60">
                          {patient.phoneNormalized
                            ? formatDigits(`0${patient.phoneNormalized}`, locale)
                            : t('patientsNoPhone')}
                        </p>
                      </div>
                    </div>
                  </td>
                  <td className={cell}>
                    <Labelled label={t('patientsSortId')} />
                    <span className="inline-flex rounded-md bg-brand-mist px-2 py-0.5 text-xs font-semibold tabular-nums dark:bg-white/10">
                      {formatDigits(patient.clinicPatientId, locale)}
                    </span>
                  </td>
                  <td className={cell}>
                    <Labelled label={`${t('patientsColAge')} · ${t('patientsGender')}`} />
                    {ageGender || <span className="text-brand-navy/40 dark:text-white/40">—</span>}
                  </td>
                  <td className={cell}>
                    <Labelled label={t('patientsRegistered')} />
                    {patient.registeredAt ? (
                      dateFormat.format(new Date(patient.registeredAt))
                    ) : (
                      <span className="text-brand-navy/40 dark:text-white/40">—</span>
                    )}
                  </td>
                  <td className={cell}>
                    <Labelled label={t('patientsVisits')} />
                    <span
                      className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-0.5 text-xs font-semibold tabular-nums ${
                        visits > 0
                          ? 'bg-brand-coral/15 text-brand-coral-action'
                          : 'bg-brand-mist text-brand-navy/55 dark:bg-white/10 dark:text-white/55'
                      }`}
                    >
                      <HistoryIcon width={14} height={14} />
                      {formatDigits(String(visits), locale)}
                    </span>
                  </td>
                  <td className={cell}>
                    <Labelled label={t('patientsLastVisit')} />
                    {patient.lastVisitAt ? (
                      dateFormat.format(new Date(patient.lastVisitAt))
                    ) : (
                      <span className="text-brand-navy/50 dark:text-white/50">{t('patientsNoVisits')}</span>
                    )}
                  </td>
                  <td className="px-4 py-3 text-right whitespace-nowrap max-md:absolute max-md:top-3 max-md:right-3 max-md:p-0">
                    <span className="inline-flex items-center gap-2">
                      {draftIds.has(patient.id) ? (
                        <span className="rounded-full bg-amber-100 px-2 py-0.5 text-xs font-medium text-amber-900 dark:bg-amber-400/20 dark:text-amber-100">
                          {t('draftBadge')}
                        </span>
                      ) : null}
                      <IconButton
                        label={t('patientsEdit')}
                        ariaLabel={`${t('patientsEdit')}: ${patient.name}`}
                        icon={PencilIcon}
                        onClick={() => onEdit(patient)}
                      />
                    </span>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>

        <ScrollSentinel onReach={onLoadMore} disabled={!hasMore || loadingMore || moreFailed} />
        <div className="flex min-h-12 items-center justify-center px-4 pb-3">
          {loadingMore ? (
            <p className="text-sm text-brand-navy/70 dark:text-white/70" role="status">
              {t('usersLoadingMore')}
            </p>
          ) : moreFailed || (hasMore && !canObserveScroll()) ? (
            <button type="button" className={secondaryButton} onClick={onLoadMore}>
              {moreFailed ? t('usersRetry') : t('usersLoadMore')}
            </button>
          ) : null}
        </div>
      </div>
    </section>
  )
}
