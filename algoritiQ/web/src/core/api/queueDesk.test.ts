/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as client from '@/core/api/client'
import { pickChamberIdWithOpenSession } from '@/core/api/queueDesk'

function snapshotOf(chamberId: string, sessionOpen: boolean) {
  return { chamberId, sessionOpen } as never
}

describe('pickChamberIdWithOpenSession', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should pick the chamber that has an open session, not the first one', async () => {
    vi.spyOn(client, 'apiFetch').mockImplementation(async (path: string) =>
      snapshotOf(path, path.includes('/c2')),
    )

    await expect(pickChamberIdWithOpenSession('tok', [{ id: 'c1' }, { id: 'c2' }, { id: 'c3' }])).resolves.toBe('c2')
  })

  it('should skip a chamber that fails to answer', async () => {
    vi.spyOn(client, 'apiFetch').mockImplementation(async (path: string) => {
      if (path.includes('/c1')) throw new Error('unreachable')
      return snapshotOf(path, path.includes('/c2'))
    })

    await expect(pickChamberIdWithOpenSession('tok', [{ id: 'c1' }, { id: 'c2' }])).resolves.toBe('c2')
  })

  it('should fall back to the first chamber when none has a session', async () => {
    vi.spyOn(client, 'apiFetch').mockImplementation(async (path: string) => snapshotOf(path, false))

    await expect(pickChamberIdWithOpenSession('tok', [{ id: 'c1' }, { id: 'c2' }])).resolves.toBe('c1')
  })

  it('should return nothing when there are no chambers', async () => {
    await expect(pickChamberIdWithOpenSession('tok', [])).resolves.toBe('')
  })
})
