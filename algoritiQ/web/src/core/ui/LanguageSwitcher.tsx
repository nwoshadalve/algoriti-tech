/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { Locale } from '@/core/i18n/messages/types'

const options: { locale: Locale; label: string; spoken: string }[] = [
  { locale: 'bn', label: 'বাংলা', spoken: 'বাংলা' },
  { locale: 'en', label: 'EN', spoken: 'English' },
]

/** Compact on phones so the header logo stays visually dominant; larger from `sm`. */
export function LanguageSwitcher() {
  const { locale, setLocale, t } = useLocale()

  return (
    <div
      className="flex h-8 items-center sm:h-10"
      role="group"
      aria-label={t('languageLabel')}
    >
      <div className="inline-flex rounded-full bg-brand-navy/[0.07] p-0.5 dark:bg-white/10">
        {options.map((option) => {
          const selected = locale === option.locale
          return (
            <button
              key={option.locale}
              type="button"
              className={[
                'flex h-7 min-w-9 items-center justify-center rounded-full px-2 text-[11px] font-bold transition-colors sm:h-9 sm:min-w-[3rem] sm:px-3 sm:text-xs',
                selected
                  ? 'bg-brand-navy text-white dark:bg-white dark:text-brand-navy'
                  : 'text-brand-navy/65 hover:text-brand-navy dark:text-white/65 dark:hover:text-white',
              ].join(' ')}
              aria-pressed={selected}
              aria-label={option.spoken}
              onClick={() => setLocale(option.locale)}
            >
              {option.label}
            </button>
          )
        })}
      </div>
    </div>
  )
}
