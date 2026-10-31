/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useMemo, useState, type FormEvent } from 'react'
import { saveChamberQueuePolicy } from '@/core/api/queue'
import type { Chamber, QueuePolicy } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { SelectField } from '@/core/ui/SelectField'
import { readSession } from '@/features/auth/session'
import { queueErrorKey } from '@/features/queue/queueErrors'
import { dayBoundaryTo12Hour, toDayBoundary24 } from '@/features/queue/queueStopTime'

type QueuePolicyModalProps = {
  policy: QueuePolicy
  chambers: Chamber[]
  initialChamberIds: string[]
  onClose: () => void
  onSaved: (saved: {
    dayBoundary: string
    chamberIds: string[]
    effectiveByChamberId: Record<string, string>
  }) => void
}

const formId = 'queue-policy-form'

const hourOptions = Array.from({ length: 12 }, (_, i) => ({
  value: String(i + 1),
  label: String(i + 1),
}))

const minuteOptions = Array.from({ length: 60 }, (_, i) => {
  const value = String(i).padStart(2, '0')
  return { value, label: value }
})

/** Automatic session stop: selected chambers and 12-hour time. */
export function QueuePolicyModal({
  policy,
  chambers,
  initialChamberIds,
  onClose,
  onSaved,
}: QueuePolicyModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const initial = useMemo(() => dayBoundaryTo12Hour(policy.dayBoundary), [policy.dayBoundary])
  const [hour, setHour] = useState(String(initial.hour))
  const [minute, setMinute] = useState(String(initial.minute).padStart(2, '0'))
  const [period, setPeriod] = useState<'AM' | 'PM'>(initial.period)
  const [selected, setSelected] = useState<Set<string>>(() => new Set(initialChamberIds))
  const [busy, setBusy] = useState(false)

  function toggleChamber(id: string) {
    setSelected((current) => {
      const next = new Set(current)
      if (next.has(id)) next.delete(id)
      else next.add(id)
      return next
    })
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    if (selected.size === 0) {
      toast.error(t('queueAutoStopSelectChamber'))
      return
    }
    const token = readSession()
    if (!token) return
    const dayBoundary = toDayBoundary24(Number(hour), Number(minute), period)
    setBusy(true)
    try {
      const effectiveByChamberId: Record<string, string> = {}
      for (const id of selected) {
        const result = await saveChamberQueuePolicy(token, id, dayBoundary)
        effectiveByChamberId[id] = result.effectivePolicy.dayBoundary
      }
      toast.success(t('queueAutoStopSaved'))
      onSaved({
        dayBoundary,
        chamberIds: [...selected],
        effectiveByChamberId,
      })
      setBusy(false)
    } catch (error) {
      toast.error(t(queueErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('queueAutoStopModalTitle')}
      description={t('queueAutoStopModalHelp')}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton type="submit" form={formId} isLoading={busy}>
            {t('queueAutoStopSave')}
          </LoadingButton>
        </>
      }
    >
      <form id={formId} className="space-y-5" onSubmit={(e) => void onSubmit(e)}>
        <fieldset className="space-y-2">
          <legend className="text-sm font-medium text-brand-navy dark:text-white">
            {t('queueAutoStopChambersLabel')}
          </legend>
          {chambers.map((chamber) => (
            <label
              key={chamber.id}
              className="flex cursor-pointer items-start gap-3 rounded-lg border border-brand-navy/10 px-3 py-2.5 text-sm dark:border-white/10"
            >
              <input
                type="checkbox"
                className="mt-0.5"
                checked={selected.has(chamber.id)}
                onChange={() => toggleChamber(chamber.id)}
              />
              <span>{chamber.name}</span>
            </label>
          ))}
        </fieldset>

        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <SelectField
            id="queue-stop-hour"
            label={t('queueAutoStopHour')}
            value={hour}
            onChange={(e) => setHour(e.target.value)}
            options={hourOptions}
          />
          <SelectField
            id="queue-stop-minute"
            label={t('queueAutoStopMinute')}
            value={minute}
            onChange={(e) => setMinute(e.target.value)}
            options={minuteOptions}
          />
          <div className="col-span-2 sm:col-span-1">
            <SelectField
              id="queue-stop-period"
              label={t('queueAutoStopPeriod')}
              value={period}
              onChange={(e) => setPeriod(e.target.value as 'AM' | 'PM')}
              options={[
                { value: 'AM', label: t('queueAutoStopAm') },
                { value: 'PM', label: t('queueAutoStopPm') },
              ]}
            />
          </div>
        </div>
        <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('queueAutoStopNextDayNote')}</p>
      </form>
    </Modal>
  )
}
