/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState } from 'react'
import { previewIssueToken } from '@/core/api/board'
import { searchPatients } from '@/core/api/patients'
import type { IssuePreview, PatientSummary, QueueTypeBoardControl } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PlusIcon, SearchIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'
import { useDebouncedValue } from '@/core/ui/useDebouncedValue'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { queueDisplayName } from '@/features/board/boardFormat'
import { IssueConfirmModal } from '@/features/board/IssueConfirmModal'
import { RegisterPatientModal } from '@/features/board/RegisterPatientModal'
import { ApiError } from '@/core/api/client'

type PatientEntrySectionProps = {
  chamberId: string
  sessionOpen: boolean
  queueControls: QueueTypeBoardControl[]
  onIssued: () => void
}

type Mode = 'idle' | 'search'

type Dialog =
  | { kind: 'register'; phone: string; confirmDuplicate: boolean }
  | { kind: 'issue'; preview: IssuePreview }
  | null

/** Inline patient search, registration, and token issue on the board. */
export function PatientEntrySection({
  chamberId,
  sessionOpen,
  queueControls,
  onIssued,
}: PatientEntrySectionProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [mode, setMode] = useState<Mode>('idle')
  const [query, setQuery] = useState('')
  const debouncedQuery = useDebouncedValue(query, 350)
  const [results, setResults] = useState<PatientSummary[]>([])
  const [searching, setSearching] = useState(false)
  const [selected, setSelected] = useState<PatientSummary | null>(null)
  const [queueTypeId, setQueueTypeId] = useState('')
  const [feeBdt, setFeeBdt] = useState('')
  const [previewBusy, setPreviewBusy] = useState(false)
  const [dialog, setDialog] = useState<Dialog>(null)

  const enabledTypes = queueControls
  const defaultQueueId = enabledTypes.length === 1 ? enabledTypes[0]!.queueTypeId : queueTypeId

  const runSearch = useCallback(
    async (text: string) => {
      const token = readSession()
      if (!token || text.trim().length < 2) {
        setResults([])
        return
      }
      setSearching(true)
      try {
        const patients = await searchPatients(token, text.trim())
        setResults(patients)
      } catch (error) {
        toast.error(t(boardErrorKey(error)))
        setResults([])
      } finally {
        setSearching(false)
      }
    },
    [t, toast],
  )

  useEffect(() => {
    if (mode !== 'search') return
    void runSearch(debouncedQuery)
  }, [debouncedQuery, mode, runSearch])

  function openSearch() {
    setMode('search')
    setQuery('')
    setResults([])
    setSelected(null)
  }

  function openNew() {
    setMode('search')
    setQuery('')
    setResults([])
    setSelected(null)
  }

  async function previewIssue() {
    const token = readSession()
    if (!token || !selected || !defaultQueueId || previewBusy) return
    setPreviewBusy(true)
    const fee = feeBdt.trim() ? Number(feeBdt) : undefined
    try {
      const preview = await previewIssueToken(token, chamberId, selected.id, defaultQueueId, fee)
      setDialog({ kind: 'issue', preview })
    } catch (error) {
      if (error instanceof ApiError && error.code === 'duplicate_phone_needs_confirm') {
        toast.error(t('boardErrorDuplicatePhone'))
      } else if (error instanceof ApiError && error.code === 'patient_has_active_token') {
        toast.error(t('boardErrorActiveToken'))
      } else {
        toast.error(t(boardErrorKey(error)))
      }
    } finally {
      setPreviewBusy(false)
    }
  }

  const queueOptions = enabledTypes.map((row) => ({
    value: row.queueTypeId,
    label: queueDisplayName(locale, row.englishName, row.bengaliName),
  }))

  return (
    <Card as="section" labelledBy="board-patient-entry">
      <h2 id="board-patient-entry" className="font-semibold">
        {t('boardPatientActionsTitle')}
      </h2>
      {!sessionOpen ? (
        <p className="mt-2 text-sm text-brand-navy/65 dark:text-white/65">{t('boardSessionRequired')}</p>
      ) : (
        <>
          <div className="mt-4 flex flex-col gap-2 sm:flex-row">
            <IconButton
              label={t('boardNewPatient')}
              icon={PlusIcon}
              onClick={openNew}
              labelOnSmall
            />
            <IconButton
              label={t('boardExistingPatient')}
              icon={SearchIcon}
              onClick={openSearch}
              labelOnSmall
            />
          </div>

          {mode === 'search' ? (
            <div className="mt-4 space-y-4 border-t border-brand-navy/10 pt-4 dark:border-white/10">
              <TextField
                id="patient-search"
                label={t('boardSearchLabel')}
                hint={t('boardSearchHint')}
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                autoComplete="off"
              />
              {searching ? <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearching')}</p> : null}
              {results.length > 0 ? (
                <ul className="space-y-2" aria-label={t('boardSearchResults')}>
                  {results.map((patient) => (
                    <li key={patient.id}>
                      <button
                        type="button"
                        onClick={() => {
                          setSelected(patient)
                          if (enabledTypes.length === 1) {
                            setQueueTypeId(enabledTypes[0]!.queueTypeId)
                          }
                        }}
                        className={[
                          'w-full rounded-xl border px-4 py-3 text-left text-sm transition-colors',
                          selected?.id === patient.id
                            ? 'border-brand-coral bg-brand-coral/5'
                            : 'border-brand-navy/10 hover:bg-brand-mist/60 dark:border-white/10 dark:hover:bg-white/5',
                        ].join(' ')}
                      >
                        <p className="font-semibold">{patient.bengaliName}</p>
                        <p className="text-brand-navy/70 dark:text-white/70">
                          {patient.clinicPatientId}
                          {patient.ageLabel ? ` · ${patient.ageLabel}` : ''}
                        </p>
                      </button>
                    </li>
                  ))}
                </ul>
              ) : null}
              {query.trim().length >= 2 && !searching && results.length === 0 ? (
                <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearchEmpty')}</p>
              ) : null}
              <button
                type="button"
                className={secondaryButton}
                onClick={() =>
                  setDialog({
                    kind: 'register',
                    phone: query.trim(),
                    confirmDuplicate: false,
                  })
                }
              >
                {t('boardRegisterNew')}
              </button>

              {selected ? (
                <div className="space-y-3 rounded-xl border border-brand-navy/10 bg-brand-mist/30 p-4 dark:border-white/10 dark:bg-white/5">
                  <p className="text-sm font-medium">{t('boardIssueFor', { name: selected.bengaliName })}</p>
                  {enabledTypes.length > 1 ? (
                    <SelectField
                      id="issue-queue"
                      label={t('boardFieldQueue')}
                      value={queueTypeId}
                      onChange={(event) => setQueueTypeId(event.target.value)}
                      options={[{ value: '', label: t('boardChooseQueue') }, ...queueOptions]}
                    />
                  ) : null}
                  <TextField
                    id="issue-fee"
                    label={t('boardFieldFee')}
                    inputMode="numeric"
                    value={feeBdt}
                    onChange={(event) => setFeeBdt(event.target.value)}
                  />
                  <LoadingButton
                    isLoading={previewBusy}
                    loadingLabel={t('boardWorking')}
                    disabled={!defaultQueueId}
                    onClick={() => void previewIssue()}
                  >
                    {t('boardIssuePreview')}
                  </LoadingButton>
                </div>
              ) : null}
            </div>
          ) : null}
        </>
      )}

      {dialog?.kind === 'register' ? (
        <RegisterPatientModal
          initialPhone={dialog.phone}
          confirmDuplicatePhone={dialog.confirmDuplicate}
          onClose={() => setDialog(null)}
          onRegistered={(patient) => {
            setDialog(null)
            setSelected(patient)
            setMode('search')
          }}
        />
      ) : null}
      {dialog?.kind === 'issue' ? (
        <IssueConfirmModal
          chamberId={chamberId}
          preview={dialog.preview}
          onClose={() => setDialog(null)}
          onIssued={() => {
            setDialog(null)
            setSelected(null)
            setQuery('')
            setMode('idle')
            onIssued()
          }}
        />
      ) : null}
    </Card>
  )
}
