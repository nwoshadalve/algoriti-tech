/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import {
  MAX_ZOOM,
  MIN_ZOOM,
  clampCrop,
  coverScale,
  sourceRect,
  startCrop,
  zoomTo,
} from '@/features/settings/cropMath'

// A landscape 600 x 400 picture in a 200 px window: cover scale 0.5.
const W = 600
const H = 400
const SIDE = 200

describe('crop math', () => {
  it('should cover the window with the smaller side of the picture', () => {
    expect(coverScale(W, H, SIDE)).toBeCloseTo(0.5)
    expect(coverScale(H, W, SIDE)).toBeCloseTo(0.5)
  })

  it('should start centred on the middle square', () => {
    const rect = sourceRect(startCrop, W, H, SIDE)

    expect(rect.size).toBeCloseTo(400)
    expect(rect.sx).toBeCloseTo(100)
    expect(rect.sy).toBeCloseTo(0)
  })

  it('should show a smaller square when zoomed in', () => {
    const rect = sourceRect({ zoom: 2, x: 0, y: 0 }, W, H, SIDE)

    expect(rect.size).toBeCloseTo(200)
    expect(rect.sx).toBeCloseTo(200)
    expect(rect.sy).toBeCloseTo(100)
  })

  it('should move the view the other way from the drag', () => {
    const rect = sourceRect({ zoom: 1, x: -50, y: 0 }, W, H, SIDE)

    // Picture dragged 50 px left: the window sees 100 picture px further right.
    expect(rect.sx).toBeCloseTo(200)
  })

  it('should keep the picture covering the window', () => {
    // At zoom 1 the picture is 300 x 200 on screen: 50 px of slack each way, none up or down.
    const right = clampCrop({ zoom: 1, x: 500, y: 500 }, W, H, SIDE)
    const left = clampCrop({ zoom: 1, x: -500, y: -500 }, W, H, SIDE)

    expect([right.x, right.y]).toEqual([50, 0])
    expect(left.x).toBe(-50)
    expect(Math.abs(left.y)).toBe(0)
  })

  it('should allow more room once zoomed in', () => {
    const crop = clampCrop({ zoom: 2, x: 500, y: 500 }, W, H, SIDE)

    expect(crop.x).toBeCloseTo(200)
    expect(crop.y).toBeCloseTo(100)
  })

  it('should keep the zoom within its limits', () => {
    expect(clampCrop({ zoom: 0.2, x: 0, y: 0 }, W, H, SIDE).zoom).toBe(MIN_ZOOM)
    expect(clampCrop({ zoom: 99, x: 0, y: 0 }, W, H, SIDE).zoom).toBe(MAX_ZOOM)
  })

  it('should keep what is at the centre while zooming', () => {
    const before = { zoom: 2, x: 60, y: 40 }
    const after = zoomTo(before, 3, W, H, SIDE)
    const centreBefore = sourceRect(before, W, H, SIDE)
    const centreAfter = sourceRect(after, W, H, SIDE)

    expect(centreAfter.sx + centreAfter.size / 2).toBeCloseTo(centreBefore.sx + centreBefore.size / 2)
    expect(centreAfter.sy + centreAfter.size / 2).toBeCloseTo(centreBefore.sy + centreBefore.size / 2)
  })

  it('should always stay inside the picture', () => {
    for (const crop of [
      { zoom: 1, x: 999, y: -999 },
      { zoom: 4, x: -999, y: 999 },
      { zoom: 2.5, x: 30, y: 30 },
    ]) {
      const rect = sourceRect(clampCrop(crop, W, H, SIDE), W, H, SIDE)

      expect(rect.sx).toBeGreaterThanOrEqual(-0.001)
      expect(rect.sy).toBeGreaterThanOrEqual(-0.001)
      expect(rect.sx + rect.size).toBeLessThanOrEqual(W + 0.001)
      expect(rect.sy + rect.size).toBeLessThanOrEqual(H + 0.001)
    }
  })
})
