/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { updateUser } from '@/core/api/users'
import type { ManagedUser } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { readSession } from '@/features/auth/session'
import { usersErrorKey } from '@/features/users/usersErrorMessages'

type DisableUserModalProps = {
  user: ManagedUser
  onClose: () => void
  onDisabled: (user: ManagedUser) => void
}

/** Asks before a person is blocked from signing in. */
export function DisableUserModal({ user, onClose, onDisabled }: DisableUserModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const [busy, setBusy] = useState(false)
  const name = user.displayName || user.username

  async function confirm() {
    const token = readSession()
    if (!token || busy) return
    setBusy(true)
    try {
      const saved = await updateUser(token, user.id, {
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        status: 'inactive',
      })
      toast.success(t('usersDisabled'))
      onDisabled(saved)
    } catch (error) {
      toast.error(t(usersErrorKey(error)))
      setBusy(false)
    }
  }

  return (
    <Modal
      title={t('usersDisableTitle')}
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
            {t('usersDisableConfirm')}
          </LoadingButton>
        </>
      }
    >
      <p className="text-sm leading-relaxed">{t('usersDisableBody', { name })}</p>
    </Modal>
  )
}
