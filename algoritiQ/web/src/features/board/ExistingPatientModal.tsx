/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState } from 'react'
import { previewIssueToken } from '@/core/api/queueDesk'
import { searchPatients } from '@/core/api/patients'
import type { IssuePreview, PatientSummary, QueueTypeBoardControl } from '@/core/api/types'
import { ApiError } from '@/core/api/client'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'
import { useDebouncedValue } from '@/core/ui/useDebouncedValue'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { queueDisplayName } from '@/features/board/boardFormat'
import { IssueConfirmModal } from '@/features/board/IssueConfirmModal'
import { RegisterPatientModal } from '@/features/board/RegisterPatientModal'

type ExistingPatientModalProps = {
  chamberId: string
  queueControls: QueueTypeBoardControl[]
  initialQuery?: string
  onClose: () => void
  onIssued: () => void
}

type Step = { kind: 'search' } | { kind: 'issue'; preview: IssuePreview }

/** Search, select, and issue a token for a returning patient. */
export function ExistingPatientModal({
  chamberId,
  queueControls,
  initialQuery = '',
  onClose,
  onIssued,
}: ExistingPatientModalProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [query, setQuery] = useState(initialQuery)
  const debouncedQuery = useDebouncedValue(query, 350)
  const [results, setResults] = useState<PatientSummary[]>([])
  const [searching, setSearching] = useState(false)
  const [selected, setSelected] = useState<PatientSummary | null>(null)
  const [queueTypeId, setQueueTypeId] = useState('')
  const [feeBdt, setFeeBdt] = useState('')
  const [previewBusy, setPreviewBusy] = useState(false)
  const [step, setStep] = useState<Step>({ kind: 'search' })
  const [registerOpen, setRegisterOpen] = useState(false)
  const [registerPhone, setRegisterPhone] = useState('')

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
    void runSearch(debouncedQuery)
  }, [debouncedQuery, runSearch])

  useEffect(() => {
    if (enabledTypes.length === 1) {
      setQueueTypeId(enabledTypes[0]!.queueTypeId)
    }
  }, [enabledTypes])

  async function previewIssue() {
    const token = readSession()
    if (!token || !selected || !defaultQueueId || previewBusy) return
    setPreviewBusy(true)
    const fee = feeBdt.trim() ? Number(feeBdt) : undefined
    try {
      const preview = await previewIssueToken(token, chamberId, selected.id, defaultQueueId, fee)
      setStep({ kind: 'issue', preview })
    } catch (error) {
      if (error instanceof ApiError && error.code === 'patient_has_active_token') {
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

  if (step.kind === 'issue') {
    return (
      <IssueConfirmModal
        chamberId={chamberId}
        preview={step.preview}
        onClose={() => setStep({ kind: 'search' })}
        onIssued={() => {
          onIssued()
          onClose()
        }}
      />
    )
  }

  return (
    <>
      <Modal
        title={t('boardExistingPatient')}
        description={t('boardSearchHint')}
        onClose={onClose}
        size="lg"
        footer={
          <button type="button" className={secondaryButton} onClick={onClose}>
            {t('actionCancel')}
          </button>
        }
      >
        <div className="space-y-4">
          <TextField
            id="patient-search"
            label={t('boardSearchLabel')}
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            autoComplete="off"
          />
          {searching ? <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearching')}</p> : null}
          {results.length > 0 ? (
            <ul className="max-h-40 space-y-2 overflow-y-auto" aria-label={t('boardSearchResults')}>
              {results.map((patient) => (
                <li key={patient.id}>
                  <button
                    type="button"
                    onClick={() => setSelected(patient)}
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
            onClick={() => {
              setRegisterPhone(query.trim())
              setRegisterOpen(true)
            }}
          >
            {t('boardRegisterNew')}
          </button>

          {selected ? (
            <div className="space-y-3 border-t border-brand-navy/10 pt-4 dark:border-white/10">
              <p className="text-sm font-medium">{t('boardIssueFor', { name: selected.bengaliName })}</p>
              {enabledTypes.length > 1 ? (
                <SelectField
                  id="issue-queue"
                  label={`${t('boardFieldQueue')} *`}
                  value={queueTypeId}
                  onChange={(event) => setQueueTypeId(event.target.value)}
                  options={[{ value: '', label: t('boardChooseQueue') }, ...queueOptions]}
                />
              ) : enabledTypes[0] ? (
                <p className="rounded-xl bg-brand-mist/80 px-3 py-2 text-sm font-medium dark:bg-white/10">
                  {queueDisplayName(locale, enabledTypes[0].englishName, enabledTypes[0].bengaliName)}
                </p>
              ) : null}
              <div className="grid gap-3 sm:grid-cols-3">
                <TextField
                  id="issue-fee"
                  label={t('boardFieldFee')}
                  inputMode="numeric"
                  value={feeBdt}
                  onChange={(event) => setFeeBdt(event.target.value)}
                />
              </div>
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
      </Modal>
      {registerOpen ? (
        <RegisterPatientModal
          initialPhone={registerPhone}
          chamberId={chamberId}
          queueControls={queueControls}
          onClose={() => setRegisterOpen(false)}
          onRegistered={() => {
            setRegisterOpen(false)
            onClose()
            onIssued()
          }}
        />
      ) : null}
    </>
  )
}
