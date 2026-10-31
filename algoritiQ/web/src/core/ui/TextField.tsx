/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { InputHTMLAttributes } from 'react'

type TextFieldProps = {
  id: string
  label: string
  hint?: string
  error?: string
} & InputHTMLAttributes<HTMLInputElement>

export function TextField({ id, label, hint, error, className, ...inputProps }: TextFieldProps) {
  return (
    <div className="space-y-1.5">
      <label htmlFor={id} className="block text-sm font-medium text-brand-navy dark:text-white">
        {label}
      </label>
      <input
        id={id}
        aria-invalid={error ? true : undefined}
        aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
        className={[
          'block min-h-12 w-full rounded-lg border bg-white px-3 py-2.5 text-base text-brand-navy shadow-sm outline-none transition-colors',
          'placeholder:text-brand-navy/40',
          'focus-visible:ring-2 focus-visible:ring-brand-coral/50 focus-visible:ring-offset-2 focus-visible:ring-offset-brand-mist dark:focus-visible:ring-offset-brand-navy',
          'dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white dark:placeholder:text-white/40',
          error
            ? 'border-red-500 dark:border-red-400'
            : 'border-brand-navy/15 dark:border-brand-navy-line',
          className,
        ]
          .filter(Boolean)
          .join(' ')}
        {...inputProps}
      />
      {hint && !error ? (
        <p id={`${id}-hint`} className="text-xs text-brand-navy/60 dark:text-white/60">
          {hint}
        </p>
      ) : null}
      {error ? (
        <p id={`${id}-error`} className="text-xs text-red-600 dark:text-red-300" role="alert">
          {error}
        </p>
      ) : null}
    </div>
  )
}
