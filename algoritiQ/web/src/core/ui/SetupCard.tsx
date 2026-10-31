/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ReactNode } from 'react'

type SetupCardProps = {
  children: ReactNode
  labelledBy: string
}

export function SetupCard({ children, labelledBy }: SetupCardProps) {
  return (
    <section
      aria-labelledby={labelledBy}
      className="rounded-2xl border border-brand-navy/10 bg-white p-5 shadow-lg shadow-brand-navy/[0.06] dark:border-brand-navy-line dark:bg-brand-navy-raised dark:shadow-none min-[400px]:p-6 sm:p-8 lg:rounded-3xl lg:p-10"
    >
      {children}
    </section>
  )
}
