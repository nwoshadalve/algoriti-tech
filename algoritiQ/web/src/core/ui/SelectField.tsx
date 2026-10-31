/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { SelectHTMLAttributes } from 'react'

type SelectFieldProps = {
  id: string
  label: string
  options: { value: string; label: string }[]
  /** Hide the label visually (it stays for screen readers). */
  hideLabel?: boolean
} & Omit<SelectHTMLAttributes<HTMLSelectElement>, 'id'>

/** A native select with the same look as the text fields. */
export function SelectField({
  id,
  label,
  options,
  hideLabel = false,
  className = '',
  ...rest
}: SelectFieldProps) {
  return (
    <div className="space-y-1.5">
      <label
        htmlFor={id}
        className={hideLabel ? 'sr-only' : 'block text-sm font-medium text-brand-navy dark:text-white'}
      >
        {label}
      </label>
      <select
        id={id}
        className={[
          'block min-h-11 w-full rounded-lg border border-brand-navy/15 bg-white px-3 py-2 text-sm text-brand-navy shadow-sm outline-none',
          'focus-visible:ring-2 focus-visible:ring-brand-coral/50',
          'dark:border-brand-navy-line dark:bg-brand-navy-raised dark:text-white',
          className,
        ].join(' ')}
        {...rest}
      >
        {options.map((option) => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
    </div>
  )
}
