/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import type { PatientGender } from '@/core/api/types'

/** The patient form as it is typed. */
export type PatientFormValues = {
  name: string
  phone: string
  age: string
  gender: PatientGender | ''
  hasPaperFile: boolean
  queueTypeId: string
  feeBdt: string
  /** A free visit: no fee is taken. */
  isFree: boolean
}

export const emptyPatientForm: PatientFormValues = {
  name: '',
  phone: '',
  age: '',
  gender: '',
  hasPaperFile: false,
  queueTypeId: '',
  feeBdt: '',
  isFree: false,
}

function samePatientForm(a: PatientFormValues, b: PatientFormValues): boolean {
  return (
    a.name.trim() === b.name.trim() &&
    a.phone.trim() === b.phone.trim() &&
    a.age.trim() === b.age.trim() &&
    a.gender === b.gender &&
    a.hasPaperFile === b.hasPaperFile &&
    a.queueTypeId === b.queueTypeId &&
    a.feeBdt.trim() === b.feeBdt.trim() &&
    a.isFree === b.isFree
  )
}

type PatientDraftsValue = {
  drafts: Record<string, PatientFormValues>
  putDraft: (key: string, values: PatientFormValues) => void
  clearDraft: (key: string) => void
}

const PatientDraftsContext = createContext<PatientDraftsValue | null>(null)

/**
 * Patient forms that were left before saving, by form (`desk-new:<chamber>`,
 * `page-new`, `edit:<patientId>`). Kept in memory while the person is signed
 * in, so a form closed by mistake, or left for another screen, comes back as
 * it was until it is saved or discarded. Nothing is written to the browser.
 */
export function PatientDraftsProvider({ children }: { children: ReactNode }) {
  const [drafts, setDrafts] = useState<Record<string, PatientFormValues>>({})
  const putDraft = useCallback((key: string, values: PatientFormValues) => {
    setDrafts((current) => ({ ...current, [key]: values }))
  }, [])
  const clearDraft = useCallback((key: string) => {
    setDrafts((current) => {
      if (!(key in current)) return current
      const next = { ...current }
      delete next[key]
      return next
    })
  }, [])
  const value = useMemo(() => ({ drafts, putDraft, clearDraft }), [drafts, putDraft, clearDraft])
  return <PatientDraftsContext.Provider value={value}>{children}</PatientDraftsContext.Provider>
}

const noDrafts: PatientDraftsValue = {
  drafts: {},
  putDraft: () => {},
  clearDraft: () => {},
}

export function usePatientDrafts(): PatientDraftsValue {
  return useContext(PatientDraftsContext) ?? noDrafts
}

/**
 * The state of one patient form with its draft. [baseline] is the form as it
 * opens without a draft (empty for a new patient, the saved values for an
 * edit); a form equal to it has no draft. With [ignoreDraft] the form starts
 * from the baseline whatever draft there is.
 */
export function usePatientFormDraft(
  key: string,
  baseline: PatientFormValues,
  options: { ignoreDraft?: boolean } = {},
) {
  const { drafts, putDraft, clearDraft } = usePatientDrafts()
  const [saved] = useState(baseline)
  const baselineRef = useRef(saved)
  const [initial] = useState(() => (options.ignoreDraft ? undefined : drafts[key]))
  const [values, setValuesState] = useState<PatientFormValues>(initial ?? baseline)
  const [restored, setRestored] = useState(initial !== undefined)
  const valuesRef = useRef(values)

  const setValues = useCallback(
    (patch: Partial<PatientFormValues>) => {
      const next = { ...valuesRef.current, ...patch }
      valuesRef.current = next
      setValuesState(next)
      if (samePatientForm(next, baselineRef.current)) clearDraft(key)
      else putDraft(key, next)
    },
    [key, putDraft, clearDraft],
  )

  /** Throws the draft away and goes back to the saved form. */
  const discard = useCallback(() => {
    valuesRef.current = baselineRef.current
    setValuesState(baselineRef.current)
    setRestored(false)
    clearDraft(key)
  }, [key, clearDraft])

  /** The form was saved: nothing is left to keep. */
  const finish = useCallback(() => clearDraft(key), [key, clearDraft])

  return {
    values,
    setValues,
    restored,
    dirty: !samePatientForm(values, saved),
    discard,
    finish,
  }
}
