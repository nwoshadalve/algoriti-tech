/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

/** The left column beside the sign-in cards on wide screens. */
export function AuthAside() {
  const { t } = useLocale()
  return (
    <div className="space-y-4 lg:sticky lg:top-8 lg:pt-2">
      <h1 className="text-3xl font-semibold tracking-tight text-brand-navy dark:text-white xl:text-4xl xl:leading-tight">
        {t('welcomeTitle')}
      </h1>
      <p className="max-w-md text-base leading-relaxed text-brand-navy/75 dark:text-white/75 xl:text-lg">
        {t('welcomeIntro')}
      </p>
    </div>
  )
}
