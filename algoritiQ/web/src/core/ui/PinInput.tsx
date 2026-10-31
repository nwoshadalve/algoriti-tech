/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useId } from 'react'

type PinInputProps = {
  label: string
  value: string
  onChange: (value: string) => void
  length?: number
  error?: string
  /** Called once when the last digit is typed. */
  onComplete?: (pin: string) => void
  disabled?: boolean
  autoFocus?: boolean
  id?: string
}

/** A masked, digits-only box for a PIN: big, centred, with the numeric keypad on phones. */
export function PinInput({
  label,
  value,
  onChange,
  length = 6,
  error,
  onComplete,
  disabled,
  autoFocus,
  id,
}: PinInputProps) {
  const generated = useId()
  const inputId = id ?? generated

  return (
    <div className="space-y-1.5">
      <label htmlFor={inputId} className="block text-sm font-medium">
        {label}
      </label>
      <input
        id={inputId}
        type="password"
        inputMode="numeric"
        pattern="[0-9]*"
        maxLength={length}
        autoComplete="off"
        autoFocus={autoFocus}
        disabled={disabled}
        value={value}
        aria-invalid={error ? true : undefined}
        aria-describedby={error ? `${inputId}-error` : undefined}
        onChange={(event) => {
          const digits = event.target.value.replace(/\D/g, '').slice(0, length)
          onChange(digits)
          if (digits.length === length) onComplete?.(digits)
        }}
        className={[
          'block min-h-14 w-full rounded-lg border bg-white px-3 py-2.5 text-center text-2xl tracking-[0.6em] shadow-sm outline-none',
          'focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:bg-brand-navy dark:text-white',
          error ? 'border-red-500 dark:border-red-400' : 'border-brand-navy/15 dark:border-brand-navy-line',
        ].join(' ')}
      />
      {error ? (
        <p id={`${inputId}-error`} className="text-xs text-red-600 dark:text-red-300" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  )
}
