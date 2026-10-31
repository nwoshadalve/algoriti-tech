/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { deleteChamber } from '@/core/api/chambers'
import type { Chamber } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { chamberError } from '@/features/license/chamberErrors'

type DeleteChamberModalProps = {
  chamber: Chamber
  onClose: () => void
  onDeleted: () => void
}

/** Asks before a chamber is removed, and says what happens to the people assigned to it. */
export function DeleteChamberModal({ chamber, onClose, onDeleted }: DeleteChamberModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      await deleteChamber(token, chamber.id)
      toast.success(t('chamberDeleted'))
      onDeleted()
    } catch (error) {
      toast.error(t(chamberError(error).key))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('chamberDeleteTitle')}
      size="sm"
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('usersSaving')}
            onClick={() => void confirm()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('chamberDeleteConfirm')}
          </LoadingButton>
        </>
      }
    >
      <p className="text-sm leading-relaxed">{t('chamberDeleteBody', { name: chamber.name })}</p>
    </Modal>
  )
}
