/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import {
  acquireAvatarObjectUrl,
  releaseAvatarObjectUrl,
} from '@/core/ui/avatarObjectUrlCache'

describe('avatar object URL cache', () => {
  it('should reuse the same URL until the blob changes', () => {
    const blob = new Blob(['a'], { type: 'image/jpeg' })
    const first = acquireAvatarObjectUrl('doctor:1', blob)
    const second = acquireAvatarObjectUrl('doctor:1', blob)

    expect(second).toBe(first)

    releaseAvatarObjectUrl('doctor:1')
    releaseAvatarObjectUrl('doctor:1')
  })

  it('should replace the URL when the blob changes', () => {
    const firstBlob = new Blob(['a'], { type: 'image/jpeg' })
    const secondBlob = new Blob(['b'], { type: 'image/jpeg' })
    const firstUrl = acquireAvatarObjectUrl('doctor:2', firstBlob)
    const secondUrl = acquireAvatarObjectUrl('doctor:2', secondBlob)

    expect(secondUrl).not.toBe(firstUrl)

    releaseAvatarObjectUrl('doctor:2')
  })
})
