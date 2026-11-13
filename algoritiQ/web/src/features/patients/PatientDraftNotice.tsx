/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'

type PatientDraftNoticeProps = {
  /** There is something typed that is not saved. */
  visible: boolean
  /** The form was filled from a draft when it opened. */
  restored: boolean
  onDiscard: () => void
  disabled?: boolean
}

/** Tells that what was typed is kept as a draft, and lets the person throw it away. */
export function PatientDraftNotice({ visible, restored, onDiscard, disabled }: PatientDraftNoticeProps) {
  const { t } = useLocale()
  if (!visible) return null
  return (
    <div
      role="status"
      className="mb-4 flex items-center justify-between gap-3 rounded-lg bg-brand-mist px-3 py-2 text-sm dark:bg-white/10"
    >
      <span>{restored ? t('draftRestored') : t('draftKept')}</span>
      <button
        type="button"
        className="shrink-0 font-semibold text-brand-coral-action disabled:opacity-50"
        disabled={disabled}
        onClick={onDiscard}
      >
        {t('draftDiscard')}
      </button>
    </div>
  )
}
