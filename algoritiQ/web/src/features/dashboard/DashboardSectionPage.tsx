/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

type DashboardSectionPageProps = {
  titleKey: 'navOverview' | 'navUsers' | 'navMonitoring'
  placeholderKey: 'placeholderOverview' | 'placeholderUsers' | 'placeholderMonitoring'
}

/** Empty section shell — real content will replace the placeholder panel. */
export function DashboardSectionPage({ titleKey, placeholderKey }: DashboardSectionPageProps) {
  const { t } = useLocale()

  return (
    <div>
      <div className="mb-6 sm:mb-8">
        <h1 className="text-xl font-semibold tracking-tight sm:text-2xl lg:text-3xl">
          {t(titleKey)}
        </h1>
      </div>
      <div
        className="rounded-2xl border border-dashed border-brand-navy/20 bg-white/60 px-5 py-10 text-center text-sm leading-relaxed text-brand-navy/70 sm:px-8 sm:py-14 dark:border-white/15 dark:bg-brand-navy-raised/40 dark:text-white/70"
        aria-hidden="false"
      >
        {t(placeholderKey)}
      </div>
    </div>
  )
}
