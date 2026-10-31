/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ReactNode } from 'react'

type CardProps = {
  children: ReactNode
  className?: string
  as?: 'section' | 'div'
  labelledBy?: string
}

/** White panel used for every block of dashboard content. */
export function Card({ children, className = '', as: Tag = 'div', labelledBy }: CardProps) {
  return (
    <Tag
      aria-labelledby={labelledBy}
      className={[
        'rounded-2xl border border-brand-navy/10 bg-white p-5 shadow-sm sm:p-6 dark:border-white/10 dark:bg-brand-navy-raised dark:shadow-none',
        className,
      ].join(' ')}
    >
      {children}
    </Tag>
  )
}
