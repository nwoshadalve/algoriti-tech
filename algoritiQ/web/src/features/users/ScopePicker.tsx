/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { UsersContextTarget } from '@/core/api/types'

type ScopePickerProps = {
  label: string
  targets: UsersContextTarget[]
  selected: string[]
  onChange: (ids: string[]) => void
  disabled?: boolean
}

/** Checkboxes for chamber or doctor assignments. */
export function ScopePicker({ label, targets, selected, onChange, disabled }: ScopePickerProps) {
  const { t } = useLocale()

  if (targets.length === 0) {
    return (
      <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('usersNoTargets')}</p>
    )
  }

  function toggle(id: string) {
    if (disabled) return
    if (selected.includes(id)) {
      onChange(selected.filter((value) => value !== id))
    } else {
      onChange([...selected, id])
    }
  }

  return (
    <fieldset className="space-y-2">
      <legend className="text-sm font-semibold text-brand-navy dark:text-white">{label}</legend>
      <ul className="grid gap-2 sm:grid-cols-2">
        {targets.map((target) => {
          const checked = selected.includes(target.id)
          return (
            <li key={target.id}>
              <label
                className={[
                  'flex min-h-11 cursor-pointer items-center gap-3 rounded-xl border px-3 py-2 text-sm transition-colors',
                  checked
                    ? 'border-brand-coral/50 bg-brand-coral/5 dark:border-brand-coral/40 dark:bg-brand-coral/10'
                    : 'border-brand-navy/15 bg-white hover:bg-brand-mist dark:border-white/15 dark:bg-brand-navy-raised dark:hover:bg-white/5',
                  disabled ? 'cursor-not-allowed opacity-60' : '',
                ].join(' ')}
              >
                <input
                  type="checkbox"
                  className="size-4 shrink-0 accent-brand-coral-action"
                  checked={checked}
                  disabled={disabled}
                  onChange={() => toggle(target.id)}
                />
                <span className="min-w-0 truncate text-brand-navy dark:text-white">{target.name}</span>
              </label>
            </li>
          )
        })}
      </ul>
    </fieldset>
  )
}
