/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useId, useRef, useState, type DragEvent } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { ArrowUpIcon, HardDriveIcon } from '@/core/ui/icons'

type BackupUploadZoneProps = {
  disabled?: boolean
  onPick: (file: File) => void
}

function isZipFile(file: File): boolean {
  const name = file.name.toLowerCase()
  return name.endsWith('.zip') || file.type === 'application/zip' || file.type === 'application/x-zip-compressed'
}

/** Drag-and-drop or browse to upload a clinic backup zip. */
export function BackupUploadZone({ disabled = false, onPick }: BackupUploadZoneProps) {
  const { t } = useLocale()
  const toast = useToast()
  const inputId = useId()
  const inputRef = useRef<HTMLInputElement>(null)
  const [dragOver, setDragOver] = useState(false)

  const inactive = disabled

  function accept(file: File | undefined) {
    if (!file || inactive) return
    if (!isZipFile(file)) {
      toast.error(t('backupUploadOnlyZip'))
      return
    }
    onPick(file)
  }

  function onDragOver(event: DragEvent) {
    event.preventDefault()
    if (!inactive) setDragOver(true)
  }

  function onDragLeave(event: DragEvent) {
    event.preventDefault()
    setDragOver(false)
  }

  function onDrop(event: DragEvent) {
    event.preventDefault()
    setDragOver(false)
    accept(event.dataTransfer.files[0])
  }

  function openPicker() {
    if (!inactive) inputRef.current?.click()
  }

  return (
    <div className="mt-4">
      <input
        ref={inputRef}
        id={inputId}
        type="file"
        accept=".zip,application/zip,application/x-zip-compressed"
        className="sr-only"
        disabled={inactive}
        onChange={(event) => {
          accept(event.target.files?.[0])
          event.target.value = ''
        }}
      />
      <div
        role="button"
        tabIndex={inactive ? -1 : 0}
        aria-disabled={inactive}
        aria-busy={false}
        aria-labelledby={`${inputId}-label`}
        onClick={openPicker}
        onKeyDown={(event) => {
          if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault()
            openPicker()
          }
        }}
        onDragOver={onDragOver}
        onDragLeave={onDragLeave}
        onDrop={onDrop}
        className={[
          'flex min-h-[8.5rem] flex-col items-center justify-center gap-2.5 rounded-xl border-2 border-dashed px-3 py-5 text-center transition-colors sm:min-h-[9rem]',
          'focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-coral',
          inactive ? 'cursor-not-allowed opacity-60' : 'cursor-pointer',
          dragOver
            ? 'border-brand-coral bg-brand-coral/10 dark:border-brand-coral dark:bg-brand-coral/15'
            : 'border-brand-navy/20 bg-brand-mist/40 hover:border-brand-coral/45 hover:bg-brand-coral/5 dark:border-white/20 dark:bg-white/5 dark:hover:border-brand-coral/50 dark:hover:bg-brand-coral/10',
        ].join(' ')}
      >
        {dragOver ? (
          <>
            <span className="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-coral/15 text-brand-coral dark:bg-brand-coral/20">
              <ArrowUpIcon className="h-6 w-6" aria-hidden />
            </span>
            <p className="text-sm font-medium text-brand-navy dark:text-white">{t('backupUploadDropTitle')}</p>
          </>
        ) : (
          <>
            <span className="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-coral/15 text-brand-coral dark:bg-brand-coral/20">
              <HardDriveIcon className="h-6 w-6" aria-hidden />
            </span>
            <div className="max-w-xs space-y-0.5">
              <p id={`${inputId}-label`} className="text-sm font-semibold text-brand-navy dark:text-white">
                {t('backupUploadDropTitle')}
              </p>
              <p className="text-xs leading-relaxed text-brand-navy/65 dark:text-white/65">
                {t('backupUploadDropHint')}
              </p>
            </div>
            <span className="inline-flex min-h-10 items-center rounded-lg border border-brand-navy/20 bg-white px-3 text-xs font-semibold text-brand-navy dark:border-white/25 dark:bg-brand-navy dark:text-white sm:text-sm">
              {t('backupUploadButton')}
            </span>
          </>
        )}
      </div>
      <p className="mt-2 text-center text-xs text-brand-navy/55 dark:text-white/55">{t('backupUploadOnlyZip')}</p>
    </div>
  )
}
