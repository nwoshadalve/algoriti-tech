/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { BrandLoader } from '@/core/ui/BrandLoader'
import { useLocale } from '@/core/i18n/LocaleProvider'

type PagePreloaderProps = {
  /** Overrides default localized "Loading…" for screen readers. */
  label?: string
  className?: string
}

/** Centred page/section wait state — reuse on any async screen. */
export function PagePreloader({ label, className = '' }: PagePreloaderProps) {
  const { t } = useLocale()
  const message = label ?? t('loadingLabel')

  return (
    <div
      className={['flex flex-col items-center justify-center py-16 sm:py-20', className]
        .filter(Boolean)
        .join(' ')}
    >
      <BrandLoader semanticLabel={message} dotSize={10} />
      <p className="mt-4 text-sm text-brand-navy/60 dark:text-white/60">{message}</p>
    </div>
  )
}
