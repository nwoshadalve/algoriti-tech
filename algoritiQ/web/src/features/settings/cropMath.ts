/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
/** Where the picture sits in the square crop window. */
export type Crop = {
  /** 1 fits the picture to the window (it covers it); larger zooms in. */
  zoom: number
  /** Offset of the picture's centre from the window's centre, in window pixels. */
  x: number
  y: number
}

export const MIN_ZOOM = 1
export const MAX_ZOOM = 4

export const startCrop: Crop = { zoom: MIN_ZOOM, x: 0, y: 0 }

/** Display scale at zoom 1: the smaller side of the picture just fills the window. */
export function coverScale(width: number, height: number, side: number): number {
  return Math.max(side / width, side / height)
}

export function clampZoom(zoom: number): number {
  return Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, zoom))
}

/** Keeps the picture covering the whole window, so no empty edge shows. */
export function clampCrop(crop: Crop, width: number, height: number, side: number): Crop {
  const zoom = clampZoom(crop.zoom)
  const scale = coverScale(width, height, side) * zoom
  const maxX = Math.max(0, (width * scale - side) / 2)
  const maxY = Math.max(0, (height * scale - side) / 2)
  return {
    zoom,
    x: Math.min(maxX, Math.max(-maxX, crop.x)),
    y: Math.min(maxY, Math.max(-maxY, crop.y)),
  }
}

/** Changes the zoom and keeps what is at the window's centre where it is. */
export function zoomTo(crop: Crop, zoom: number, width: number, height: number, side: number): Crop {
  const next = clampZoom(zoom)
  const ratio = next / crop.zoom
  return clampCrop({ zoom: next, x: crop.x * ratio, y: crop.y * ratio }, width, height, side)
}

/** The square of the original picture, in its own pixels, that the window shows. */
export function sourceRect(crop: Crop, width: number, height: number, side: number) {
  const scale = coverScale(width, height, side) * crop.zoom
  return {
    sx: width / 2 + (-side / 2 - crop.x) / scale,
    sy: height / 2 + (-side / 2 - crop.y) / scale,
    size: side / scale,
  }
}

export type SourceRect = ReturnType<typeof sourceRect>
