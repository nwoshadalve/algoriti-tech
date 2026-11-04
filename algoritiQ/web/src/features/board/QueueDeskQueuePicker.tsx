/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { QueueTypeBoardControl } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { queueDisplayName } from '@/features/board/boardFormat'

type QueueDeskQueuePickerProps = {
  controls: QueueTypeBoardControl[]
  selectedId: string | null
  onSelected: (queueTypeId: string) => void
  disabled?: boolean
  errorText?: string
}

/** Chip picker for queue type — matches the tablet desk dialog. */
export function QueueDeskQueuePicker({
  controls,
  selectedId,
  onSelected,
  disabled,
  errorText,
}: QueueDeskQueuePickerProps) {
  const { t, locale } = useLocale()

  return (
    <div className="flex flex-col gap-2">
      <span className="text-sm font-medium text-brand-navy dark:text-white">
        {t('boardFieldQueue')} *
      </span>
      <div className="flex flex-wrap gap-2">
        {controls.map((control) => {
          const selected = control.queueTypeId === selectedId
          return (
            <button
              key={control.queueTypeId}
              type="button"
              disabled={disabled}
              aria-pressed={selected}
              onClick={() => onSelected(control.queueTypeId)}
              className={[
                'inline-flex min-h-11 min-w-[8rem] flex-col items-start rounded-xl border px-3 py-2 text-left text-sm transition',
                selected
                  ? 'border-brand-coral-action bg-brand-coral-action/10 ring-2 ring-brand-coral-action'
                  : 'border-brand-navy/15 bg-white hover:border-brand-navy/30 dark:border-white/15 dark:bg-brand-navy-raised dark:hover:border-white/30',
                disabled ? 'cursor-not-allowed opacity-60' : '',
              ].join(' ')}
            >
              <span className="font-semibold">
                {queueDisplayName(locale, control.englishName, control.bengaliName)}
              </span>
              <span className="text-xs text-brand-navy/65 dark:text-white/65">
                {t('boardWaitingCount', { count: String(control.waitingCount) })}
              </span>
            </button>
          )
        })}
      </div>
      {errorText ? <p className="text-sm text-brand-coral-action">{errorText}</p> : null}
    </div>
  )
}
