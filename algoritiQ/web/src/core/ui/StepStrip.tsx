/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

type StepStripProps = {
  /** Names of the steps, in order. */
  steps: string[]
  /** 1-based. */
  activeStep: number
  /** Accessible name of the strip, e.g. "Setup progress". */
  label: string
}

/**
 * "Step 2 of 3 · name" with one bar per step, for screens where the step list
 * beside the card is hidden (below `lg`).
 */
export function StepStrip({ steps, activeStep, label }: StepStripProps) {
  const { t } = useLocale()

  return (
    <div className="mb-4 lg:hidden" role="group" aria-label={label}>
      <ol className="flex gap-1.5" aria-hidden="true">
        {steps.map((step, index) => (
          <li
            key={step}
            className={[
              'h-1.5 flex-1 rounded-full',
              index + 1 === activeStep
                ? 'bg-brand-coral'
                : index + 1 < activeStep
                  ? 'bg-brand-navy dark:bg-white'
                  : 'bg-brand-navy/15 dark:bg-white/15',
            ].join(' ')}
          />
        ))}
      </ol>
      <p className="mt-2 text-sm font-medium text-brand-navy/80 dark:text-white/80" aria-live="polite">
        {t('setupProgressStep', { current: activeStep, total: steps.length })}
        <span className="text-brand-navy/60 dark:text-white/60">{' · '}</span>
        {steps[activeStep - 1]}
      </p>
    </div>
  )
}
