/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useTheme } from '@/core/theme/ThemeProvider'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { Tooltip } from '@/core/ui/Tooltip'

function SunIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <circle cx="12" cy="12" r="4" stroke="currentColor" strokeWidth="2" />
      <path
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"
      />
    </svg>
  )
}

function MoonIcon({ size = 16 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" aria-hidden="true">
      <path
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"
      />
    </svg>
  )
}

export function ThemeToggle() {
  const { resolved, toggleTheme } = useTheme()
  const { t } = useLocale()
  const isDark = resolved === 'dark'

  return (
    <Tooltip label={isDark ? t('themeLight') : t('themeDark')} placement="bottom">
      <button
        type="button"
        className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full border border-brand-navy/35 bg-white text-brand-navy shadow-sm transition-colors hover:border-brand-navy/55 hover:bg-brand-mist sm:h-9 sm:w-9 dark:border-white/35 dark:bg-brand-navy-raised dark:text-white dark:shadow-none dark:hover:bg-brand-navy-line"
        onClick={toggleTheme}
        aria-label={isDark ? t('themeLight') : t('themeDark')}
      >
        <span className="sm:hidden">{isDark ? <SunIcon size={16} /> : <MoonIcon size={16} />}</span>
        <span className="hidden sm:inline">{isDark ? <SunIcon size={18} /> : <MoonIcon size={18} />}</span>
      </button>
    </Tooltip>
  )
}
