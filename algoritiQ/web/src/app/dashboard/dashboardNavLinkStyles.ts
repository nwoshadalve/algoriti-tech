/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Shared sidebar link chrome for top-level and nested items. */
export function dashboardNavLinkClass(isActive: boolean, nested = false): string {
  return [
    'group flex min-h-11 items-center gap-3 rounded-xl text-sm font-medium transition-colors motion-reduce:transition-none',
    nested ? 'py-2 pl-9 pr-3' : 'px-3 py-2.5',
    'focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none',
    isActive
      ? nested
        ? 'bg-brand-navy/10 text-brand-navy dark:bg-white/15 dark:text-white'
        : 'bg-brand-navy text-white dark:bg-white dark:text-brand-navy'
      : 'text-brand-navy/75 hover:bg-brand-navy/5 hover:text-brand-navy dark:text-white/75 dark:hover:bg-white/10 dark:hover:text-white',
  ].join(' ')
}
