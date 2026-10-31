/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as boardApi from '@/core/api/board'
import * as chambersApi from '@/core/api/chambers'
import type { Account } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import { AuthContext } from '@/features/auth/authContext'
import * as session from '@/features/auth/session'
import { AdminQueueBoardPage } from '@/features/board/AdminQueueBoardPage'

const admin: Account = {
  id: 'a1',
  username: 'admin',
  displayName: 'Admin User',
  firstName: 'Admin',
  lastName: 'User',
  email: 'admin@test',
  phone: '',
  photoVersion: 0,
  role: 'admin',
}

const receptionist: Account = { ...admin, id: 'r1', username: 'desk', role: 'receptionist' }

function renderBoard(account: Account) {
  return render(
    <LocaleProvider>
      <ToastProvider>
        <AuthContext.Provider
          value={{
            state: { status: 'signedIn', account },
            signIn: vi.fn(),
            signInWithPin: vi.fn(),
            signOut: vi.fn(),
            updateAccount: vi.fn(),
          }}
        >
          <AdminQueueBoardPage />
        </AuthContext.Provider>
      </ToastProvider>
    </LocaleProvider>,
  )
}

describe('AdminQueueBoardPage', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should block non-admin users', () => {
    renderBoard(receptionist)
    expect(screen.getByText('Only an administrator can use the queue board.')).toBeInTheDocument()
  })

  it('should load for administrators', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([
      { id: 'c1', name: 'Main', location: '', phone: '' },
    ])
    vi.spyOn(boardApi, 'getBoardSnapshot').mockResolvedValue({
      chamberId: 'c1',
      chamberName: 'Main',
      sessionId: null,
      sessionOpen: false,
      calledToken: null,
      queueControls: [],
      tokens: [],
      printerBusyTokenId: null,
    })

    renderBoard(admin)
    expect(await screen.findByRole('heading', { name: 'Board' })).toBeInTheDocument()
    expect(screen.getByText('Session not open')).toBeInTheDocument()
  })
})
