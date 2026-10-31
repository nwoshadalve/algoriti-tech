/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

/** Shown instead of a blank page when the app crashes while rendering. */
export function ErrorScreen({ error }: { error: Error }) {
  const { t } = useLocale()

  return (
    <main className="flex min-h-dvh items-center justify-center bg-brand-mist px-4 py-8 text-brand-navy dark:bg-brand-navy dark:text-white">
      <section
        role="alert"
        className="w-full max-w-md rounded-2xl border border-brand-navy/10 bg-white p-6 shadow-lg shadow-brand-navy/[0.06] dark:border-brand-navy-line dark:bg-brand-navy-raised dark:shadow-none"
      >
        <h1 className="text-2xl font-semibold tracking-tight">{t('errorScreenTitle')}</h1>
        <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
          {t('errorScreenBody')}
        </p>
        <p className="mt-4 rounded-xl bg-brand-mist px-3 py-2 font-mono text-xs break-words text-brand-navy/80 dark:bg-brand-navy dark:text-white/80">
          {error.name}: {error.message}
        </p>
        <button
          type="button"
          onClick={() => window.location.reload()}
          className="mt-5 inline-flex min-h-11 w-full items-center justify-center rounded-xl bg-brand-coral-action px-4 text-sm font-semibold text-white focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:ring-offset-2 focus-visible:outline-none"
        >
          {t('errorScreenReload')}
        </button>
      </section>
    </main>
  )
}
