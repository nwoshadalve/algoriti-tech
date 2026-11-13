/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'
import { useFeeCodes } from '@/features/fees/useFeeCodes'

type FeeFieldProps = {
  id: string
  /** The amount in BDT as text; empty is no fee. */
  value: string
  onChange: (value: string) => void
  disabled?: boolean
  /** Shown under the free field only (a list cannot hold a bad value). */
  error?: string
  /** The visit is free: no fee is taken. */
  free?: boolean
  /** With this, an "F" toggle sits beside the fee; turning it on hides the fee and empties it. */
  onFreeChange?: (free: boolean) => void
}

const NONE = ''
/** A fee the visit already has that matches no code (a removed code, or typed before codes existed). */
const CURRENT = '__current'

/**
 * The fee of a visit in a desk form. While the admin has defined no fee codes
 * this is the free amount field it always was. Once codes exist it is a list
 * of them, starting on "No fee"; picking a code fills in its amount, so the
 * form reads the fee from `value` either way.
 */
export function FeeField({ free = false, onFreeChange, ...props }: FeeFieldProps) {
  const { t } = useLocale()
  if (!onFreeChange) return <FeeInput {...props} />
  return (
    <div className="flex items-end gap-3">
      <div className="min-w-0 flex-1">
        {free ? (
          <p className="py-2.5 font-semibold text-brand-navy dark:text-white" data-testid={`${props.id}-free`}>
            {t('boardFreeLabel')}
          </p>
        ) : (
          <FeeInput {...props} />
        )}
      </div>
      <button
        type="button"
        id={`${props.id}-free-toggle`}
        aria-pressed={free}
        aria-label={t('boardFreeTooltip')}
        title={t('boardFreeTooltip')}
        disabled={props.disabled}
        onClick={() => {
          if (!free) props.onChange('')
          onFreeChange(!free)
        }}
        className={`mb-0.5 h-10 min-w-10 rounded-lg border px-3 text-sm font-bold transition-colors disabled:opacity-50 ${
          free
            ? 'border-brand-navy bg-brand-navy text-white dark:border-white dark:bg-white dark:text-brand-navy'
            : 'border-brand-navy/20 text-brand-navy hover:bg-brand-navy/5 dark:border-white/20 dark:text-white dark:hover:bg-white/10'
        }`}
      >
        {t('boardFreeShort')}
      </button>
    </div>
  )
}

function FeeInput({ id, value, onChange, disabled, error }: Omit<FeeFieldProps, 'free' | 'onFreeChange'>) {
  const { t } = useLocale()
  const codes = useFeeCodes()
  // Two codes can share an amount; remember which one was picked.
  const [picked, setPicked] = useState('')

  if (codes.length === 0) {
    return (
      <TextField
        id={id}
        label={t('boardFieldFee')}
        inputMode="numeric"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        disabled={disabled}
        error={error}
      />
    )
  }

  const text = value.trim()
  const amount = /^\d+$/.test(text) ? Number(text) : null
  const match =
    amount === null
      ? undefined
      : (codes.find((fee) => fee.id === picked && fee.amountBdt === amount) ??
        codes.find((fee) => fee.amountBdt === amount))
  const selected = text === '' ? NONE : (match?.id ?? CURRENT)

  return (
    <SelectField
      id={id}
      label={t('boardFieldFee')}
      value={selected}
      disabled={disabled}
      onChange={(event) => {
        const next = event.target.value
        setPicked(next)
        if (next === NONE) onChange('')
        else if (next !== CURRENT) {
          const fee = codes.find((entry) => entry.id === next)
          if (fee) onChange(String(fee.amountBdt))
        }
      }}
      options={[
        { value: NONE, label: t('boardFeeNone') },
        ...codes.map((fee) => ({ value: fee.id, label: `${fee.code} — ${fee.amountBdt}` })),
        ...(text !== '' && !match ? [{ value: CURRENT, label: text }] : []),
      ]}
    />
  )
}
