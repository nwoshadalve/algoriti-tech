/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useRef, useState, type KeyboardEvent, type PointerEvent } from 'react'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { secondaryButton } from '@/core/ui/buttonStyles'
import {
  MAX_ZOOM,
  MIN_ZOOM,
  clampCrop,
  coverScale,
  sourceRect,
  startCrop,
  zoomTo,
  type Crop,
} from '@/features/settings/cropMath'
import type { Picture } from '@/features/settings/pictureSource'

type PhotoCropperProps = {
  picture: Picture
  onCancel: () => void
  /** Receives the chosen square; the dialog shows a spinner until it settles. */
  onSave: (square: Blob) => Promise<void>
}

const KEY_STEP = 12
const FALLBACK_SIDE = 288

/**
 * Lets the person place the photo inside a round window: drag or swipe to move,
 * pinch, scroll or use the slider to zoom, arrow keys to nudge.
 */
export function PhotoCropper({ picture, onCancel, onSave }: PhotoCropperProps) {
  const { t } = useLocale()
  const stage = useRef<HTMLDivElement>(null)
  const pointers = useRef(new Map<number, { x: number; y: number }>())
  const pinch = useRef<{ distance: number; zoom: number } | null>(null)
  const [side, setSide] = useState(FALLBACK_SIDE)
  const [crop, setCrop] = useState<Crop>(startCrop)
  const [saving, setSaving] = useState(false)

  const { width, height } = picture
  const scale = coverScale(width, height, side) * crop.zoom

  // The window's size follows the screen; keep the picture covering it.
  useEffect(() => {
    const element = stage.current
    if (!element) return
    const measure = () => {
      const next = element.clientWidth || FALLBACK_SIDE
      setSide(next)
      setCrop((current) => clampCrop(current, width, height, next))
    }
    measure()
    if (typeof ResizeObserver === 'undefined') return
    const observer = new ResizeObserver(measure)
    observer.observe(element)
    return () => observer.disconnect()
  }, [width, height])

  // A wheel must zoom the picture, not scroll the page behind: needs a non-passive listener.
  useEffect(() => {
    const element = stage.current
    if (!element) return
    const onWheel = (event: WheelEvent) => {
      event.preventDefault()
      setCrop((current) =>
        zoomTo(current, current.zoom * Math.exp(-event.deltaY * 0.0015), width, height, side),
      )
    }
    element.addEventListener('wheel', onWheel, { passive: false })
    return () => element.removeEventListener('wheel', onWheel)
  }, [width, height, side])

  function onPointerDown(event: PointerEvent<HTMLDivElement>) {
    event.currentTarget.setPointerCapture?.(event.pointerId)
    pointers.current.set(event.pointerId, { x: event.clientX, y: event.clientY })
    if (pointers.current.size === 2) {
      const [a, b] = [...pointers.current.values()]
      pinch.current = { distance: Math.hypot(a.x - b.x, a.y - b.y) || 1, zoom: crop.zoom }
    }
  }

  function onPointerMove(event: PointerEvent<HTMLDivElement>) {
    const before = pointers.current.get(event.pointerId)
    if (!before) return
    const now = { x: event.clientX, y: event.clientY }
    pointers.current.set(event.pointerId, now)

    if (pointers.current.size >= 2 && pinch.current) {
      const [a, b] = [...pointers.current.values()]
      const distance = Math.hypot(a.x - b.x, a.y - b.y)
      const start = pinch.current
      setCrop((current) =>
        zoomTo(current, start.zoom * (distance / start.distance), width, height, side),
      )
      return
    }
    const dx = now.x - before.x
    const dy = now.y - before.y
    setCrop((current) =>
      clampCrop({ ...current, x: current.x + dx, y: current.y + dy }, width, height, side),
    )
  }

  function onPointerEnd(event: PointerEvent<HTMLDivElement>) {
    pointers.current.delete(event.pointerId)
    pinch.current = null
  }

  function onKeyDown(event: KeyboardEvent<HTMLDivElement>) {
    const moves: Record<string, [number, number]> = {
      ArrowLeft: [-KEY_STEP, 0],
      ArrowRight: [KEY_STEP, 0],
      ArrowUp: [0, -KEY_STEP],
      ArrowDown: [0, KEY_STEP],
    }
    const move = moves[event.key]
    if (move) {
      event.preventDefault()
      setCrop((current) =>
        clampCrop({ ...current, x: current.x + move[0], y: current.y + move[1] }, width, height, side),
      )
    } else if (event.key === '+' || event.key === '=') {
      setCrop((current) => zoomTo(current, current.zoom + 0.1, width, height, side))
    } else if (event.key === '-') {
      setCrop((current) => zoomTo(current, current.zoom - 0.1, width, height, side))
    }
  }

  async function save() {
    setSaving(true)
    try {
      await onSave(await picture.render(sourceRect(crop, width, height, side)))
    } finally {
      setSaving(false)
    }
  }

  return (
    <Modal
      title={t('cropTitle')}
      description={t('cropHelp')}
      size="sm"
      busy={saving}
      onClose={onCancel}
      footer={
        <>
          <button type="button" disabled={saving} onClick={onCancel} className={secondaryButton}>
            {t('cropCancel')}
          </button>
          <LoadingButton
            isLoading={saving}
            loadingLabel={t('settingsPhotoWorking')}
            onClick={() => void save()}
            className="sm:w-auto sm:min-w-40"
          >
            {t('cropSave')}
          </LoadingButton>
        </>
      }
    >
      <div
        ref={stage}
        tabIndex={0}
        role="application"
        aria-label={t('cropStageLabel')}
        data-testid="crop-stage"
        className="relative mx-auto aspect-square w-full max-w-72 cursor-grab touch-none overflow-hidden rounded-xl bg-black outline-none select-none focus-visible:ring-2 focus-visible:ring-brand-coral active:cursor-grabbing"
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerEnd}
        onPointerCancel={onPointerEnd}
        onKeyDown={onKeyDown}
      >
        <img
          src={picture.url}
          alt=""
          draggable={false}
          data-testid="crop-image"
          className="pointer-events-none absolute top-1/2 left-1/2 max-w-none"
          style={{
            width: width * scale,
            height: height * scale,
            transform: `translate(calc(-50% + ${crop.x}px), calc(-50% + ${crop.y}px))`,
          }}
        />
        <div
          aria-hidden="true"
          className="pointer-events-none absolute inset-0 rounded-full shadow-[0_0_0_999px_rgba(0,0,0,0.55)] ring-2 ring-white/80"
        />
      </div>

      <label className="mt-4 flex items-center gap-3 text-sm font-medium">
        <span className="shrink-0">{t('cropZoom')}</span>
        <input
          type="range"
          min={MIN_ZOOM}
          max={MAX_ZOOM}
          step={0.01}
          value={crop.zoom}
          onChange={(event) =>
            setCrop((current) => zoomTo(current, Number(event.target.value), width, height, side))
          }
          className="h-11 min-w-0 flex-1 accent-brand-coral-action"
        />
      </label>
    </Modal>
  )
}
