/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useRef, useState } from 'react'
import { issueToken } from '@/core/api/queueDesk'
import { searchPatients } from '@/core/api/patients'
import type { MessageKey } from '@/core/i18n/messages/types'
import type { PatientSummary, QueueTypeBoardControl } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import {
  deskSearchGraphemeCount,
  newBoardCommandId,
  parseDeskNumber,
} from '@/features/board/boardFormat'
import { afterDeskIssue } from '@/features/board/deskAfterIssue'
import { EditPatientModal } from '@/features/board/EditPatientModal'
import { QueueDeskQueuePicker } from '@/features/board/QueueDeskQueuePicker'
import { RegisterPatientModal } from '@/features/board/RegisterPatientModal'

type ExistingPatientModalProps = {
  chamberId: string
  queueControls: QueueTypeBoardControl[]
  onClose: () => void
  onDone: () => void | Promise<void>
}

function patientMeta(patient: PatientSummary, t: (key: MessageKey) => string): string {
  const parts = [
    patient.clinicPatientId,
    patient.phoneNormalized ? `0${patient.phoneNormalized}` : '',
    patient.ageLabel ?? '',
    patient.gender === 'male'
      ? t('boardGenderMale')
      : patient.gender === 'female'
        ? t('boardGenderFemale')
        : patient.gender === 'other'
          ? t('boardGenderOther')
          : '',
  ]
  return parts.filter(Boolean).join(' · ')
}

/** Search, pick, and issue — same two-step flow as the tablet desk. */
export function ExistingPatientModal({
  chamberId,
  queueControls,
  onClose,
  onDone,
}: ExistingPatientModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<PatientSummary[]>([])
  const [searching, setSearching] = useState(false)
  const [searchFailed, setSearchFailed] = useState(false)
  const [selected, setSelected] = useState<PatientSummary | null>(null)
  const [queueTypeId, setQueueTypeId] = useState('')
  const [feeBdt, setFeeBdt] = useState('')
  const [issuing, setIssuing] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [registerOpen, setRegisterOpen] = useState(false)
  const [editOpen, setEditOpen] = useState(false)
  const searchSeq = useRef(0)
  const pauseRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const longEnough = deskSearchGraphemeCount(query) >= 2

  useEffect(() => {
    if (queueControls.length === 1) {
      setQueueTypeId(queueControls[0]!.queueTypeId)
    }
  }, [queueControls])

  const runSearch = useCallback(
    async (text: string) => {
      const token = readSession()
      if (!token) return
      const seq = ++searchSeq.current
      setSearching(true)
      setSearchFailed(false)
      try {
        const patients = await searchPatients(token, text)
        if (seq !== searchSeq.current) return
        setResults(patients)
      } catch {
        if (seq !== searchSeq.current) return
        setResults([])
        setSearchFailed(true)
      } finally {
        if (seq === searchSeq.current) setSearching(false)
      }
    },
    [],
  )

  useEffect(() => {
    if (pauseRef.current) clearTimeout(pauseRef.current)
    if (!longEnough) {
      searchSeq.current++
      setResults([])
      setSearching(false)
      setSearchFailed(false)
      return
    }
    setSearching(true)
    pauseRef.current = setTimeout(() => void runSearch(query.trim()), 250)
    return () => {
      if (pauseRef.current) clearTimeout(pauseRef.current)
    }
  }, [query, longEnough, runSearch])

  async function issue() {
    const token = readSession()
    if (!token || !selected || issuing || !queueTypeId) return
    setSubmitted(true)
    if (!queueTypeId) {
      toast.error(t('boardErrorValidation'))
      return
    }
    setIssuing(true)
    const fee = parseDeskNumber(feeBdt)
    try {
      const issued = await issueToken(token, chamberId, {
        commandId: newBoardCommandId(),
        patientId: selected.id,
        queueTypeId,
        feeBdt: fee,
      })
      onClose()
      await afterDeskIssue(issued, onDone, toast, t)
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setIssuing(false)
    }
  }

  function openRegisterAsNew() {
    setRegisterOpen(true)
  }

  const registerInitialPhone = /^[0-9+\s-]+$/.test(query.trim()) ? query.trim() : ''
  const registerInitialName = registerInitialPhone ? '' : query.trim()

  if (registerOpen) {
    return (
      <RegisterPatientModal
        chamberId={chamberId}
        queueControls={queueControls}
        initialPhone={registerInitialPhone}
        initialName={registerInitialName}
        onClose={() => setRegisterOpen(false)}
        onDone={async () => {
          setRegisterOpen(false)
          onClose()
          await onDone()
        }}
      />
    )
  }

  if (editOpen && selected) {
    return (
      <EditPatientModal
        token={{
          id: '',
          serial: 0,
          queueTypeId: '',
          queueEnglishName: '',
          queueBengaliName: '',
          patientId: selected.id,
          clinicPatientId: selected.clinicPatientId,
          patientBengaliName: selected.bengaliName,
          status: 'WAITING',
          issuedAt: new Date().toISOString(),
        }}
        initialPatient={selected}
        onClose={() => setEditOpen(false)}
        onSaved={(saved) => {
          if (saved) setSelected(saved)
          setEditOpen(false)
        }}
      />
    )
  }

  if (selected) {
    return (
      <Modal
        title={t('boardIssueTokenTitle')}
        busy={issuing}
        onClose={onClose}
        size="lg"
        footer={
          <>
            <button
              type="button"
              className={secondaryButton}
              disabled={issuing}
              onClick={() => setSelected(null)}
            >
              {t('boardChangePatient')}
            </button>
            <LoadingButton
              isLoading={issuing}
              loadingLabel={t('boardWorking')}
              onClick={() => void issue()}
              className="sm:w-auto sm:min-w-44"
            >
              {t('boardIssueTokenAction')}
            </LoadingButton>
          </>
        }
      >
        <div className="rounded-xl bg-brand-mist/80 p-4 dark:bg-white/10">
          <div className="flex items-start gap-3">
            <span className="flex size-11 shrink-0 items-center justify-center rounded-full bg-brand-coral/15 text-sm font-bold text-brand-coral-action">
              {selected.bengaliName.trim().charAt(0) || '?'}
            </span>
            <div className="min-w-0 flex-1">
              <p className="font-semibold">{selected.bengaliName}</p>
              <p className="text-sm text-brand-navy/65 dark:text-white/65">{patientMeta(selected, t)}</p>
            </div>
            <button
              type="button"
              className="shrink-0 text-sm font-semibold text-brand-coral-action"
              disabled={issuing}
              onClick={() => setEditOpen(true)}
            >
              {t('boardRowEditPatient')}
            </button>
          </div>
        </div>
        <div className="mt-4">
          <QueueDeskQueuePicker
            controls={queueControls}
            selectedId={queueTypeId || null}
            onSelected={setQueueTypeId}
            disabled={issuing}
            errorText={submitted && !queueTypeId ? t('boardFieldRequired') : undefined}
          />
        </div>
        <div className="mt-4">
          <TextField
            id="existing-fee"
            label={t('boardFieldFee')}
            inputMode="numeric"
            value={feeBdt}
            onChange={(event) => setFeeBdt(event.target.value)}
            disabled={issuing}
          />
        </div>
      </Modal>
    )
  }

  return (
    <Modal
      title={t('boardExistingPatient')}
      onClose={onClose}
      size="lg"
      footer={
        <>
          <button type="button" className={secondaryButton} onClick={openRegisterAsNew}>
            {t('boardRegisterNew')}
          </button>
          <button type="button" className={secondaryButton} onClick={onClose}>
            {t('actionCancel')}
          </button>
        </>
      }
    >
      <TextField
        id="patient-search"
        label={t('boardSearchLabel')}
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        placeholder={t('boardSearchHint')}
        autoComplete="off"
      />
      <div className="mt-4 min-h-[8rem]">
        {searching ? (
          <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearching')}</p>
        ) : searchFailed ? (
          <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearchFailed')}</p>
        ) : !longEnough ? (
          <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearchStart')}</p>
        ) : results.length === 0 ? (
          <p className="text-sm text-brand-navy/65 dark:text-white/65">{t('boardSearchEmpty')}</p>
        ) : (
          <ul className="max-h-52 space-y-2 overflow-y-auto" aria-label={t('boardSearchResults')}>
            {results.map((patient) => (
              <li key={patient.id}>
                <button
                  type="button"
                  onClick={() => setSelected(patient)}
                  className="flex w-full items-center gap-3 rounded-xl border border-brand-navy/10 px-4 py-3 text-left transition hover:bg-brand-mist/60 dark:border-white/10 dark:hover:bg-white/5"
                >
                  <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-brand-coral/15 text-sm font-bold">
                    {patient.bengaliName.trim().charAt(0) || '?'}
                  </span>
                  <span className="min-w-0">
                    <span className="block font-semibold">{patient.bengaliName}</span>
                    <span className="block text-sm text-brand-navy/65 dark:text-white/65">
                      {patientMeta(patient, t)}
                    </span>
                  </span>
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </Modal>
  )
}
