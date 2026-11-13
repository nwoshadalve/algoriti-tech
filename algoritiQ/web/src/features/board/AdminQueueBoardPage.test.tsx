/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as queueDeskApi from '@/core/api/queueDesk'
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
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  })
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
          <QueryClientProvider client={queryClient}>
            <AdminQueueBoardPage />
          </QueryClientProvider>
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
    expect(screen.getByText('You cannot use the queue desk with this account.')).toBeInTheDocument()
  })

  it('should load for administrators', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([
      {
        id: 'c1',
        name: 'Main',
        location: '',
        phone: '',
        patientIdPrefix: '776',
        patientIdNextSequence: 1,
      },
    ])
    vi.spyOn(queueDeskApi, 'pickChamberIdWithOpenSession').mockResolvedValue('c1')
    vi.spyOn(queueDeskApi, 'getQueueDeskSnapshot').mockResolvedValue({
      chamberId: 'c1',
      chamberName: 'Main',
      sessionId: null,
      sessionOpen: false,
      calledToken: null,
      calledTokens: [],
      queueControls: [],
      tokens: [],
      printerBusyTokenId: null,
    })

    vi.spyOn(queueDeskApi, 'searchSessionTokensCompat').mockResolvedValue({
      items: [],
      total: 0,
      counts: {},
    })

    renderBoard(admin)
    expect(await screen.findByRole('heading', { name: 'Queue desk' })).toBeInTheDocument()
    expect(await screen.findByText('Session not open')).toBeInTheDocument()
  })

  it('should render session tokens from the paged API when a session is open', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([
      {
        id: 'c1',
        name: 'Main',
        location: '',
        phone: '',
        patientIdPrefix: '776',
        patientIdNextSequence: 1,
      },
    ])
    vi.spyOn(queueDeskApi, 'pickChamberIdWithOpenSession').mockResolvedValue('c1')
    vi.spyOn(queueDeskApi, 'getQueueDeskSnapshot').mockResolvedValue({
      chamberId: 'c1',
      chamberName: 'Main',
      sessionId: 's1',
      sessionOpen: true,
      calledToken: null,
      calledTokens: [],
      queueControls: [],
      tokens: [],
      printerBusyTokenId: null,
    })
    vi.spyOn(queueDeskApi, 'searchSessionTokensCompat').mockResolvedValue({
      items: [
        {
          id: 't1',
          serial: 1001,
          queueTypeId: 'regular',
          queueEnglishName: 'Regular',
          queueBengaliName: 'Regular',
          patientId: 'p1',
          clinicPatientId: '7761',
          patientName: 'Karim',
          status: 'WAITING',
          issuedAt: '2026-11-01T09:00:00.000Z',
        },
      ],
      total: 1,
      counts: { WAITING: 1 },
    })

    renderBoard(admin)
    // The desk opens on Calling; the session table is on the Patients tab.
    const calling = await screen.findByRole('tab', { name: /Calling/ })
    expect(calling).toHaveAttribute('aria-selected', 'true')
    expect(screen.queryByText('Karim')).not.toBeInTheDocument()

    await userEvent.click(screen.getByRole('tab', { name: /Patients/ }))
    expect(screen.getByRole('tab', { name: /Patients/ })).toHaveAttribute('aria-selected', 'true')
    expect((await screen.findAllByText('Karim')).length).toBeGreaterThan(0)
    expect(queueDeskApi.getQueueDeskSnapshot).toHaveBeenCalledWith('tok', 'c1', {
      includeTokens: false,
    })
  })

  it('should show each queue with its call button on the Calling tab', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    vi.spyOn(chambersApi, 'listChambers').mockResolvedValue([
      { id: 'c1', name: 'Main', location: '', phone: '', patientIdPrefix: '776', patientIdNextSequence: 1 },
    ])
    vi.spyOn(queueDeskApi, 'pickChamberIdWithOpenSession').mockResolvedValue('c1')
    vi.spyOn(queueDeskApi, 'getQueueDeskSnapshot').mockResolvedValue({
      chamberId: 'c1',
      chamberName: 'Main',
      sessionId: 's1',
      sessionOpen: true,
      calledToken: null,
      calledTokens: [],
      queueControls: [
        {
          queueTypeId: 'regular',
          englishName: 'Regular',
          bengaliName: 'Regular',
          waitingCount: 3,
          nextSerial: 4,
          canCallNext: true,
          canRecall: false,
        },
      ],
      tokens: [],
      printerBusyTokenId: null,
    } as never)
    vi.spyOn(queueDeskApi, 'searchSessionTokensCompat').mockResolvedValue({ items: [], total: 0, counts: {} })

    renderBoard(admin)

    expect(await screen.findByText('Regular')).toBeInTheDocument()
    expect(screen.getByText('3 waiting')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Call' })).toBeEnabled()
    expect(screen.getByRole('button', { name: 'Add' })).toBeInTheDocument()
  })
})
