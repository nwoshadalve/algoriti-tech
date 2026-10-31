/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useId, useRef, useState } from 'react'
import type { Account } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { Avatar } from '@/core/ui/Avatar'
import type { PhotoSource } from '@/core/ui/useAvatarUrl'
import { Card } from '@/core/ui/Card'
import { CameraIcon, TrashIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { PhotoCropper } from '@/features/settings/PhotoCropper'
import { isAcceptedPicture, loadPicture, type Picture } from '@/features/settings/pictureSource'

type PhotoCardProps = {
  title: string
  /** Who the picture is of: the initial shown while there is none. */
  person: Pick<Account, 'firstName' | 'displayName' | 'username' | 'photoVersion'>
  /** Where the picture is fetched from; the signed-in person's own by default. */
  source?: PhotoSource
  /** TanStack Query scope for the blob cache (default: signed-in account). */
  photoScope?: string
  /** Sends the chosen square. Throws when it could not be saved. */
  onUpload: (square: Blob) => Promise<void>
  /** Throws when it could not be removed. */
  onRemove: () => Promise<void>
}

/** A round photo with upload (through the crop popup) and remove, reporting in toasts. */
export function PhotoCard({ title, person, source, photoScope, onUpload, onRemove }: PhotoCardProps) {
  const { t } = useLocale()
  const toast = useToast()
  const headingId = useId()
  const input = useRef<HTMLInputElement>(null)
  const [busy, setBusy] = useState(false)
  const [picking, setPicking] = useState<Picture | null>(null)
  const hasPhoto = person.photoVersion > 0

  // Leaving the page with the cropper open must still free the picture.
  const open = useRef<Picture | null>(null)
  useEffect(() => {
    open.current = picking
  }, [picking])
  useEffect(() => () => open.current?.dispose(), [])

  async function onPick(file: File | undefined) {
    if (!file) return
    try {
      if (!isAcceptedPicture(file)) throw new Error('unsupported')
      setPicking(await loadPicture(file))
    } catch {
      toast.error(t('settingsPhotoBad'))
    } finally {
      // The same file can be chosen again afterwards.
      if (input.current) input.current.value = ''
    }
  }

  function closeCropper() {
    picking?.dispose()
    setPicking(null)
  }

  async function save(square: Blob) {
    try {
      await onUpload(square)
      toast.success(t('settingsPhotoSaved'))
    } catch {
      toast.error(t('settingsPhotoFailed'))
    }
    closeCropper()
  }

  async function remove() {
    setBusy(true)
    try {
      await onRemove()
      toast.success(t('settingsPhotoRemoved'))
    } catch {
      toast.error(t('settingsPhotoFailed'))
    } finally {
      setBusy(false)
    }
  }

  return (
    <Card as="section" labelledBy={headingId} className="text-center">
      <h2 id={headingId} className="text-lg font-semibold">
        {title}
      </h2>
      <div className="mt-5 flex justify-center">
        <Avatar account={person} size="xl" source={source} photoScope={photoScope} />
      </div>
      <p className="mt-4 text-sm text-brand-navy/70 dark:text-white/70">{t('settingsPhotoHelp')}</p>

      <input
        ref={input}
        type="file"
        accept="image/jpeg,image/png,image/webp"
        className="sr-only"
        tabIndex={-1}
        aria-label={t('settingsPhotoUpload')}
        onChange={(event) => void onPick(event.target.files?.[0])}
      />
      <div className="mt-5 flex justify-center gap-2">
        <IconButton
          label={busy ? t('settingsPhotoWorking') : hasPhoto ? t('settingsPhotoChange') : t('settingsPhotoUpload')}
          icon={CameraIcon}
          disabled={busy}
          onClick={() => input.current?.click()}
        />
        {hasPhoto ? (
          <IconButton
            label={t('settingsPhotoRemove')}
            icon={TrashIcon}
            tone="danger"
            disabled={busy}
            onClick={() => void remove()}
          />
        ) : null}
      </div>
      {picking ? <PhotoCropper picture={picking} onCancel={closeCropper} onSave={save} /> : null}
    </Card>
  )
}
