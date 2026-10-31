/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useWorkScope } from '@/features/work/workScopeContext'

type WorkScopeContextHeaderProps = {
  compact?: boolean
}

/** Chamber or doctor the receptionist chose for this session. */
export function WorkScopeContextHeader({ compact = false }: WorkScopeContextHeaderProps) {
  const { t } = useLocale()
  const { state } = useWorkScope()
  if (state.status !== 'ready') return null

  const { selected } = state
  const detail = selected.detail?.trim()

  if (compact) {
    return (
      <p className="flex min-w-0 items-center gap-1.5 text-sm font-semibold text-brand-navy dark:text-white">
        <span className="shrink-0 text-brand-coral" aria-hidden="true">
          ●
        </span>
        <span className="truncate">{selected.name}</span>
      </p>
    )
  }

  return (
    <div className="mx-3 mb-2 rounded-2xl border border-brand-navy/10 bg-brand-mist/60 px-3 py-3 dark:border-white/10 dark:bg-white/5">
      <p className="text-xs font-semibold tracking-wide text-brand-navy/60 uppercase dark:text-white/60">
        {t('workScopeSidebarLabel')}
      </p>
      <p className="mt-1 font-semibold text-brand-navy dark:text-white">{selected.name}</p>
      {detail ? (
        <p className="mt-0.5 text-sm text-brand-navy/65 dark:text-white/65">{detail}</p>
      ) : null}
    </div>
  )
}
