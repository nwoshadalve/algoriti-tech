/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
type StepAsideProps = {
  title: string
  intro: string
  steps: string[]
  /** 1-based. */
  activeStep: number
}

/** The column beside the card on wide screens: what this is, and the steps. */
export function StepAside({ title, intro, steps, activeStep }: StepAsideProps) {
  return (
    <div className="space-y-8 lg:sticky lg:top-8 lg:pt-2">
      <div className="space-y-4">
        <h1 className="text-3xl font-semibold tracking-tight text-brand-navy dark:text-white xl:text-4xl xl:leading-tight">
          {title}
        </h1>
        <p className="max-w-md text-base leading-relaxed text-brand-navy/75 dark:text-white/75 xl:text-lg">
          {intro}
        </p>
      </div>

      <ol className="max-w-md space-y-5 border-t border-brand-navy/10 pt-8 dark:border-white/10">
        {steps.map((label, index) => {
          const number = index + 1
          const current = number === activeStep
          const done = number < activeStep
          return (
            <li key={label} className="flex gap-4">
              <span
                className={[
                  'flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-sm font-bold',
                  current
                    ? 'bg-brand-coral-action text-white'
                    : done
                      ? 'bg-brand-navy text-white dark:bg-white dark:text-brand-navy'
                      : 'bg-brand-navy/10 text-brand-navy/50 dark:bg-white/10 dark:text-white/50',
                ].join(' ')}
                aria-current={current ? 'step' : undefined}
              >
                {number}
              </span>
              <span
                className={[
                  'pt-1.5 text-base leading-relaxed',
                  current
                    ? 'font-medium text-brand-navy dark:text-white'
                    : 'text-brand-navy/70 dark:text-white/70',
                ].join(' ')}
              >
                {label}
              </span>
            </li>
          )
        })}
      </ol>
    </div>
  )
}
