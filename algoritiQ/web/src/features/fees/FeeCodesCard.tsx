/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { getFeeCodes, saveFeeCodes, type FeeCode } from '@/core/api/feeCodes'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { Card } from '@/core/ui/Card'
import { IconButton } from '@/core/ui/IconButton'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { PlusIcon, TrashIcon } from '@/core/ui/icons'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { readSession } from '@/features/auth/session'
import { feeCodesQueryKeys } from '@/features/fees/feeCodesQueryKeys'
import {
  FEE_AMOUNT_MAX,
  FEE_CODES_MAX,
  FEE_CODE_MAX_LENGTH,
  parseFeeAmount,
  validateFeeRows,
  type FeeCodeRow,
  type FeeCodeRowError,
} from '@/features/fees/feeCodesValidation'

const inputClass = (invalid: boolean) =>
  [
    'block min-h-11 w-full rounded-lg border bg-white px-3 py-2 text-sm text-brand-navy shadow-sm outline-none',
    'focus-visible:ring-2 focus-visible:ring-brand-coral/50',
    'dark:bg-brand-navy-raised dark:text-white',
    invalid
      ? 'border-red-500 dark:border-red-400'
      : 'border-brand-navy/15 dark:border-brand-navy-line',
  ].join(' ')

let nextKey = 0
const newKey = () => `row-${++nextKey}`

function toRows(codes: FeeCode[]): FeeCodeRow[] {
  return codes.map((fee) => ({
    key: newKey(),
    id: fee.id,
    code: fee.code,
    amount: String(fee.amountBdt),
  }))
}

/** What the rows would save as; two lists with the same text are the same. */
function snapshot(rows: FeeCodeRow[]): string {
  return JSON.stringify(rows.map((row) => [row.id, row.code.trim(), row.amount.trim()]))
}

/**
 * The admin's fee codes: a code and the amount it stands for. Once any exist,
 * the desk picks a code from a list instead of typing a fee. An empty list
 * keeps the free fee field.
 */
export function FeeCodesCard() {
  const { t } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const [rows, setRows] = useState<FeeCodeRow[]>([])
  const [saved, setSaved] = useState('[]')
  const [submitted, setSubmitted] = useState(false)

  const query = useQuery({
    queryKey: feeCodesQueryKeys.all,
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('missing_session')
      return getFeeCodes(token)
    },
  })

  // Start from what the tablet has; a newer answer replaces the list only
  // while nothing has been edited.
  useEffect(() => {
    if (!query.data) return
    if (snapshot(rows) !== saved) return
    const fresh = toRows(query.data)
    setRows(fresh)
    setSaved(snapshot(fresh))
    // Only a new answer from the tablet restarts the list.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query.data])

  const saveMutation = useMutation({
    mutationFn: async () => {
      const token = readSession()
      if (!token) throw new Error('missing_session')
      return saveFeeCodes(
        token,
        rows.map((row) => ({
          ...(row.id ? { id: row.id } : {}),
          code: row.code.trim(),
          amountBdt: parseFeeAmount(row.amount) ?? 0,
        })),
      )
    },
    onSuccess: (codes) => {
      const fresh = toRows(codes)
      setRows(fresh)
      setSaved(snapshot(fresh))
      setSubmitted(false)
      queryClient.setQueryData(feeCodesQueryKeys.all, codes)
      toast.success(t('feeCodesSaved'))
    },
    onError: () => toast.error(t('feeCodesSaveError')),
  })

  const errors = useMemo(() => validateFeeRows(rows), [rows])
  const dirty = snapshot(rows) !== saved

  function update(key: string, patch: Partial<FeeCodeRow>) {
    setRows((current) => current.map((row) => (row.key === key ? { ...row, ...patch } : row)))
  }

  function errorText(error: FeeCodeRowError | undefined): string | null {
    if (!error) return null
    return t(
      error === 'codeRequired'
        ? 'feeCodeErrorRequired'
        : error === 'codeDuplicate'
          ? 'feeCodeErrorDuplicate'
          : 'feeCodeErrorAmount',
    )
  }

  function save() {
    setSubmitted(true)
    if (errors.size > 0) return
    saveMutation.mutate()
  }

  return (
    <Card as="section" labelledBy="fee-codes" className="mt-6">
      <div className="flex flex-wrap items-start justify-between gap-3">
        <div className="min-w-0">
          <h2 id="fee-codes" className="text-lg font-semibold">
            {t('feeCodesTitle')}
          </h2>
          <p className="mt-1 max-w-prose text-sm text-brand-navy/70 dark:text-white/70">
            {t('feeCodesHelp')}
          </p>
        </div>
        <button
          type="button"
          className={`${secondaryButton} gap-2`}
          disabled={rows.length >= FEE_CODES_MAX || saveMutation.isPending}
          onClick={() =>
            setRows((current) => [...current, { key: newKey(), id: '', code: '', amount: '' }])
          }
        >
          <PlusIcon />
          {t('feeCodeAdd')}
        </button>
      </div>

      {query.isPending ? (
        <PagePreloader />
      ) : query.isError ? (
        <p role="alert" className="mt-4 text-sm text-red-600 dark:text-red-300">
          {t('feeCodesLoadError')}
        </p>
      ) : rows.length === 0 ? (
        <p className="mt-4 rounded-xl bg-brand-mist px-4 py-3 text-sm text-brand-navy/80 dark:bg-white/5 dark:text-white/80">
          {t('feeCodesEmpty')}
        </p>
      ) : (
        <ul className="mt-4 space-y-3">
          {rows.map((row, index) => {
            const message = submitted ? errorText(errors.get(row.key)) : null
            const codeBad = submitted && errors.get(row.key) !== undefined && errors.get(row.key) !== 'amountInvalid'
            const amountBad = submitted && errors.get(row.key) === 'amountInvalid'
            return (
              <li key={row.key}>
                <div className="flex flex-wrap items-start gap-3 sm:flex-nowrap">
                  <div className="min-w-0 flex-1 basis-40">
                    <label htmlFor={`fee-code-${row.key}`} className="mb-1 block text-xs font-medium text-brand-navy/70 dark:text-white/70">
                      {t('feeCodeFieldCode')}
                    </label>
                    <input
                      id={`fee-code-${row.key}`}
                      className={inputClass(codeBad)}
                      value={row.code}
                      maxLength={FEE_CODE_MAX_LENGTH}
                      disabled={saveMutation.isPending}
                      autoComplete="off"
                      aria-invalid={codeBad || undefined}
                      onChange={(event) => update(row.key, { code: event.target.value })}
                    />
                  </div>
                  <div className="w-36 shrink-0">
                    <label htmlFor={`fee-amount-${row.key}`} className="mb-1 block text-xs font-medium text-brand-navy/70 dark:text-white/70">
                      {t('feeCodeFieldAmount')}
                    </label>
                    <input
                      id={`fee-amount-${row.key}`}
                      className={inputClass(amountBad)}
                      value={row.amount}
                      inputMode="numeric"
                      maxLength={String(FEE_AMOUNT_MAX).length}
                      disabled={saveMutation.isPending}
                      autoComplete="off"
                      aria-invalid={amountBad || undefined}
                      onChange={(event) => update(row.key, { amount: event.target.value })}
                    />
                  </div>
                  <div className="pt-[1.375rem]">
                    <IconButton
                      label={t('feeCodeRemove')}
                      ariaLabel={t('feeCodeRemoveNamed', { n: index + 1 })}
                      icon={TrashIcon}
                      tone="danger"
                      disabled={saveMutation.isPending}
                      onClick={() => setRows((current) => current.filter((r) => r.key !== row.key))}
                    />
                  </div>
                </div>
                {message ? (
                  <p role="alert" className="mt-1 text-xs text-red-600 dark:text-red-300">
                    {message}
                  </p>
                ) : null}
              </li>
            )
          })}
        </ul>
      )}

      {query.isSuccess ? (
        <div className="mt-5 flex flex-wrap items-center gap-3">
          <LoadingButton
            className="!w-auto"
            isLoading={saveMutation.isPending}
            loadingLabel={t('feeCodesSaving')}
            disabled={!dirty}
            onClick={save}
          >
            {t('feeCodesSave')}
          </LoadingButton>
          {dirty ? (
            <button
              type="button"
              className={secondaryButton}
              disabled={saveMutation.isPending}
              onClick={() => {
                setRows(toRows(query.data ?? []))
                setSubmitted(false)
              }}
            >
              {t('feeCodesDiscard')}
            </button>
          ) : null}
        </div>
      ) : null}
    </Card>
  )
}
