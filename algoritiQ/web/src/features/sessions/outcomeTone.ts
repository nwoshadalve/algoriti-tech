/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { TokenStatus } from '@/core/api/types'

/** How a token ended, as one of four colours used across the session pages. */
export type OutcomeTone = 'seen' | 'missed' | 'cancelled' | 'waiting'

export const outcomeTone: Record<OutcomeTone, { text: string; bar: string; pill: string }> = {
  seen: {
    text: 'text-emerald-700 dark:text-emerald-300',
    bar: 'bg-emerald-500',
    pill: 'border-emerald-600/30 bg-emerald-50 text-emerald-950 dark:border-emerald-400/30 dark:bg-emerald-950/30 dark:text-emerald-100',
  },
  missed: {
    text: 'text-orange-700 dark:text-orange-300',
    bar: 'bg-orange-500',
    pill: 'border-orange-500/35 bg-orange-50 text-orange-950 dark:border-orange-400/35 dark:bg-orange-950/30 dark:text-orange-100',
  },
  cancelled: {
    text: 'text-slate-500 dark:text-slate-400',
    bar: 'bg-slate-400',
    pill: 'border-brand-navy/15 bg-white text-brand-navy/70 dark:border-white/15 dark:bg-brand-navy dark:text-white/70',
  },
  waiting: {
    text: 'text-amber-700 dark:text-amber-300',
    bar: 'bg-amber-400',
    pill: 'border-amber-500/40 bg-amber-50 text-amber-950 dark:border-amber-400/40 dark:bg-amber-950/40 dark:text-amber-100',
  },
}

/** The tone a token's status is shown in. */
export const statusTone: Record<TokenStatus, OutcomeTone> = {
  ENTERED: 'seen',
  SKIPPED: 'missed',
  CANCELLED: 'cancelled',
  WAITING: 'waiting',
  CALLED: 'waiting',
}
