import { useState, type InputHTMLAttributes } from 'react'
import { HiEye, HiEyeSlash } from 'react-icons/hi2'
import { useLocale } from '@/core/i18n/LocaleProvider'

type PasswordFieldProps = {
  id: string
  label: string
  hint?: string
  error?: string
} & Omit<InputHTMLAttributes<HTMLInputElement>, 'type'>

/** A password input with a Show / Hide button. */
export function PasswordField({ id, label, hint, error, ...inputProps }: PasswordFieldProps) {
  const { t } = useLocale()
  const [visible, setVisible] = useState(false)

  return (
    <div className="space-y-1.5">
      <label htmlFor={id} className="block text-sm font-medium">
        {label}
      </label>
      <div className="relative">
        <input
          id={id}
          type={visible ? 'text' : 'password'}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
          className={[
            'block min-h-12 w-full rounded-lg border bg-white py-2.5 pl-3 pr-12 text-base shadow-sm outline-none',
            'focus-visible:ring-2 focus-visible:ring-brand-coral/50 dark:bg-brand-navy dark:text-white',
            error
              ? 'border-red-500 dark:border-red-400'
              : 'border-brand-navy/15 dark:border-brand-navy-line',
          ].join(' ')}
          {...inputProps}
        />
        <button
          type="button"
          className="absolute inset-y-0 right-0 flex h-12 w-12 items-center justify-center rounded-r-lg text-brand-navy/70 hover:text-brand-navy dark:text-white/70 dark:hover:text-white"
          onClick={() => setVisible((v) => !v)}
          aria-pressed={visible}
          aria-label={visible ? t('hidePassword') : t('showPassword')}
        >
          {visible ? (
            <HiEyeSlash className="size-5 shrink-0" aria-hidden="true" />
          ) : (
            <HiEye className="size-5 shrink-0" aria-hidden="true" />
          )}
        </button>
      </div>
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
