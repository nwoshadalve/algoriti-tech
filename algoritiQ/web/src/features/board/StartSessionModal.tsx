/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'

type StartSessionModalProps = {
  busy: boolean
  onConfirm: () => void
  onClose: () => void
}

/**
 * Asks before opening today's session, as the tablet desk does. Built on
 * Modal: a bottom sheet on phones, a centred card from tablet width up.
 */
export function StartSessionModal({ busy, onConfirm, onClose }: StartSessionModalProps) {
  const { t } = useLocale()

  return (
    <Modal
      title={t('boardStartSessionTitle')}
      busy={busy}
      onClose={onClose}
      size="sm"
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            isLoading={busy}
            loadingLabel={t('boardWorking')}
            onClick={onConfirm}
            className="sm:w-auto sm:min-w-40"
          >
            {t('boardStartSession')}
          </LoadingButton>
        </>
      }
    >
      <p className="text-sm text-brand-navy/80 dark:text-white/80">{t('boardStartSessionBody')}</p>
    </Modal>
  )
}
