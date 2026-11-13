/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import * as queueDeskApi from '@/core/api/queueDesk'
import type { BoardTokenView, QueueTypeBoardControl } from '@/core/api/types'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import * as session from '@/features/auth/session'
import { CurrentCallPanel } from '@/features/board/CurrentCallPanel'
import { QueueControlsSection } from '@/features/board/QueueControlsSection'

function token(id: string, serial: number, queueTypeId: string, name: string): BoardTokenView {
  return {
    id,
    serial,
    queueTypeId,
    queueEnglishName: queueTypeId === 'regular' ? 'Regular' : 'Report',
    queueBengaliName: queueTypeId === 'regular' ? 'সাধারণ' : 'রিপোর্ট',
    patientId: `p-${id}`,
    clinicPatientId: `77${serial}`,
    patientName: name,
    status: 'CALLED',
    issuedAt: '2026-11-06T00:00:00Z',
    firstCalledAt: null,
    enteredAt: null,
    feeBdt: null,
    latestPrintStatus: null,
  } as BoardTokenView
}

const regular = token('t1', 104, 'regular', 'করিম')
const report = token('t2', 201, 'report', 'রহিম')

function wrap(ui: React.ReactElement) {
  return render(
    <LocaleProvider>
      <ToastProvider>{ui}</ToastProvider>
    </LocaleProvider>,
  )
}

describe('CurrentCallPanel with several calls', () => {
  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('should list every called patient', () => {
    wrap(<CurrentCallPanel chamberId="c1" called={[regular, report]} onRefresh={vi.fn()} onCancel={vi.fn()} />)

    expect(screen.getByText('করিম')).toBeInTheDocument()
    expect(screen.getByText('রহিম')).toBeInTheDocument()
    expect(screen.getAllByRole('button', { name: 'Patient entered' })).toHaveLength(2)
  })

  it('should mark only the patient whose button was pressed', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    const entered = vi.spyOn(queueDeskApi, 'markTokenEntered').mockResolvedValue(undefined as never)
    wrap(<CurrentCallPanel chamberId="c1" called={[regular, report]} onRefresh={vi.fn()} onCancel={vi.fn()} />)

    const second = screen.getByText('রহিম').closest('li') as HTMLElement
    await userEvent.click(within(second).getByRole('button', { name: 'Patient entered' }))

    await waitFor(() => expect(entered).toHaveBeenCalledTimes(1))
    expect(entered.mock.calls[0][1]).toBe('t2')
  })

  it('should offer Call, not Recall, for a token that came up by itself', async () => {
    vi.spyOn(session, 'readSession').mockReturnValue('tok')
    const recall = vi.spyOn(queueDeskApi, 'recallCalledToken').mockResolvedValue(undefined as never)
    const next = { ...regular, announced: false }
    wrap(<CurrentCallPanel chamberId="c1" called={[next, report]} onRefresh={vi.fn()} onCancel={vi.fn()} />)

    expect(screen.getAllByRole('button', { name: 'Recall' })).toHaveLength(1)
    await userEvent.click(screen.getByRole('button', { name: 'Call' }))

    await waitFor(() => expect(recall).toHaveBeenCalledTimes(1))
    expect(recall.mock.calls[0][3]).toBe('regular')
  })

  it('should say nobody is called when the list is empty', () => {
    wrap(<CurrentCallPanel chamberId="c1" called={[]} onRefresh={vi.fn()} onCancel={vi.fn()} />)

    expect(screen.getByText('No patient is called right now.')).toBeInTheDocument()
  })
})

describe('QueueControlsSection with several calls', () => {
  const controls: QueueTypeBoardControl[] = [
    {
      queueTypeId: 'regular',
      englishName: 'Regular',
      bengaliName: 'সাধারণ',
      waitingCount: 2,
      nextSerial: 106,
      canCallNext: false,
      canRecall: true,
    },
    {
      queueTypeId: 'report',
      englishName: 'Report',
      bengaliName: 'রিপোর্ট',
      waitingCount: 1,
      nextSerial: 202,
      canCallNext: true,
      canRecall: false,
    },
  ]

  it('should show no Call next on the queue that is calling, only on the others', () => {
    wrap(
      <QueueControlsSection
        chamberId="c1"
        controls={controls}
        calledTokens={[regular]}
        sessionOpen
        onRefresh={vi.fn()}
      />,
    )

    const callButtons = screen.getAllByRole('button', { name: 'Call next' })
    expect(callButtons).toHaveLength(1)
    expect(callButtons[0]).toBeEnabled()
    // The calling queue keeps its Recall.
    expect(screen.getAllByRole('button', { name: 'Recall' })).toHaveLength(2)
    // The queue that is calling says which serial holds it.
    expect(screen.getAllByRole('status')).toHaveLength(1)
  })
})
