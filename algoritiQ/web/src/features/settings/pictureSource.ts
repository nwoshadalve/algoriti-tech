/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { SourceRect } from '@/features/settings/cropMath'

const ACCEPTED = ['image/jpeg', 'image/png', 'image/webp']
/** Side of the saved picture. Small: it is shown at most ~130 px wide. */
const OUTPUT_SIDE = 256

export class UnsupportedPictureError extends Error {
  constructor() {
    super('unsupported_picture')
    this.name = 'UnsupportedPictureError'
  }
}

export function isAcceptedPicture(file: File): boolean {
  return ACCEPTED.includes(file.type)
}

export type Picture = {
  /** For showing it in an `<img>`. */
  url: string
  width: number
  height: number
  /** The chosen square as a small JPEG. */
  render: (rect: SourceRect) => Promise<Blob>
  /** Frees the picture's memory. */
  dispose: () => void
}

/** Decodes the file in the browser. Throws [UnsupportedPictureError] when it cannot. */
export async function loadPicture(file: File): Promise<Picture> {
  if (!isAcceptedPicture(file)) throw new UnsupportedPictureError()

  let bitmap: ImageBitmap
  try {
    bitmap = await createImageBitmap(file)
  } catch {
    throw new UnsupportedPictureError()
  }
  const url = URL.createObjectURL(file)

  return {
    url,
    width: bitmap.width,
    height: bitmap.height,
    async render({ sx, sy, size }) {
      const canvas = document.createElement('canvas')
      const side = Math.min(OUTPUT_SIDE, Math.round(size))
      canvas.width = side
      canvas.height = side
      const context = canvas.getContext('2d')
      if (!context) throw new UnsupportedPictureError()
      context.drawImage(bitmap, sx, sy, size, size, 0, 0, side, side)
      const blob = await new Promise<Blob | null>((resolve) =>
        canvas.toBlob(resolve, 'image/jpeg', 0.86),
      )
      if (!blob) throw new UnsupportedPictureError()
      return blob
    },
    dispose() {
      URL.revokeObjectURL(url)
      bitmap.close()
    },
  }
}
