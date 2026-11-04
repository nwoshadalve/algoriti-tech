/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { PersonAddIcon, PersonIcon } from '@/core/ui/icons'

type SessionPatientActionsProps = {
  sessionOpen: boolean
  onAddNew: () => void
  onAddExisting: () => void
}

/** Compact Add / Add existing controls in the session table header. */
export function SessionPatientActions({
  sessionOpen,
  onAddNew,
  onAddExisting,
}: SessionPatientActionsProps) {
  const { t } = useLocale()
  if (!sessionOpen) return null

  return (
    <div className="flex flex-wrap justify-end gap-2">
      <button
        type="button"
        className="inline-flex min-h-9 items-center gap-2 rounded-xl bg-brand-coral-action px-3 py-1.5 text-sm font-bold text-white shadow-sm transition hover:brightness-105"
        onClick={onAddNew}
        title={t('boardNewPatient')}
      >
        <span className="inline-flex h-7 w-7 items-center justify-center rounded-lg bg-white/20">
          <PersonAddIcon className="h-[18px] w-[18px]" strokeWidth={2} />
        </span>
        {t('boardAddPatientShort')}
      </button>
      <button
        type="button"
        className="inline-flex min-h-9 items-center gap-2 rounded-xl border border-brand-navy/15 bg-white px-3 py-1.5 text-sm font-bold text-brand-navy shadow-sm transition hover:shadow-md dark:border-white/15 dark:bg-brand-navy-raised dark:text-white"
        onClick={onAddExisting}
        title={t('boardExistingPatient')}
      >
        <span className="inline-flex h-7 w-7 items-center justify-center rounded-lg bg-brand-navy/8 text-brand-navy dark:bg-white/10 dark:text-white">
          <PersonIcon className="h-[18px] w-[18px]" strokeWidth={2} />
        </span>
        {t('boardAddExistingShort')}
      </button>
    </div>
  )
}
