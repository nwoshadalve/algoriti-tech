/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as authApi from '@/core/api/auth'
import * as monitoringApi from '@/core/api/monitoring'
import type { HealthService, Monitoring } from '@/core/api/monitoring'
import * as setupApi from '@/core/api/setup'
import type { Account } from '@/core/api/types'
import { saveSession } from '@/features/auth/session'
import { queryClient } from '@/core/query/queryClient'
import { renderAppAt } from '@/test/render'

const owner: Account = {
  id: 'a1',
  username: 'owner',
  displayName: 'The Owner',
  firstName: 'The',
  lastName: 'Owner',
  phone: '',
  photoVersion: 0,
  email: 'owner@clinic.test',
  role: 'admin',
}

const GB = 1024 ** 3

function reading(overrides: Partial<Record<HealthService['id'], Partial<HealthService>>> = {}): Monitoring {
  const base: HealthService[] = [
    { id: 'api', status: 'ok', uptimeSeconds: 5400, retryable: false },
    { id: 'websocket', status: 'ok', uptimeSeconds: 5400, clients: 2, retryable: false },
    { id: 'androidService', status: 'ok', uptimeSeconds: 14_400, retryable: true },
    { id: 'printer', status: 'unavailable', reason: 'printer_not_set_up', retryable: true },
    { id: 'tv', status: 'unavailable', reason: 'tv_not_connected', retryable: true },
  ]
  return {
    generatedAt: '2026-10-29T12:00:00Z',
    deviceUptimeSeconds: 90_000,
    resources: {
      cpu: { status: 'ok', percent: 12, detail: '8' },
      ram: { status: 'warning', reason: 'ram_high', percent: 96, usedBytes: 7.7 * GB, totalBytes: 8 * GB },
      storage: { status: 'ok', percent: 40, usedBytes: 40 * GB, totalBytes: 100 * GB },
      bluetooth: { status: 'failed', reason: 'bluetooth_off', detail: 'off' },
    },
    services: base.map((s) => ({ ...s, ...overrides[s.id] })),
  }
}

async function clinicSection() {
  const heading = await screen.findByRole('heading', { name: 'Printer & TV' })
  return within(heading.closest('section')!)
}

async function systemSection() {
  const heading = await screen.findByRole('heading', { name: 'Server & connectivity' })
  return within(heading.closest('section')!)
}

describe('monitoring page', () => {
  beforeEach(() => {
    queryClient.clear()
    vi.spyOn(setupApi, 'getSetupStatus').mockResolvedValue({
      adminRegistered: true,
      claimCodeRequired: false,
    })
    saveSession('tok', new Date(Date.now() + 3_600_000).toISOString())
    vi.spyOn(authApi, 'getMe').mockResolvedValue(owner)
  })

  afterEach(() => {
    vi.restoreAllMocks()
    sessionStorage.clear()
  })

  it('should show printer and TV first with status and reason', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue(reading())

    renderAppAt('/monitoring')

    const clinic = await clinicSection()
    await clinic.findByRole('heading', { name: 'POS printer' })
    expect(clinic.getByText('No printer is set up yet.')).toBeInTheDocument()
    expect(clinic.getByText('No TV app has connected.')).toBeInTheDocument()
    expect(clinic.getAllByText('Unavailable')).toHaveLength(2)
    expect(clinic.getByRole('button', { name: 'Retry POS printer' })).toBeInTheDocument()
    expect(clinic.queryByRole('button', { name: 'Retry TV app' })).not.toBeInTheDocument()

    const system = await systemSection()
    expect(system.getAllByText('Running')).toHaveLength(2)
    expect(system.queryByText('Android services')).not.toBeInTheDocument()
  })

  it('should show CPU, RAM and storage with why one is not fine', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue(reading())

    renderAppAt('/monitoring')

    await screen.findByRole('heading', { name: 'Tablet' })
    expect(screen.getByRole('progressbar', { name: 'CPU' })).toHaveAttribute('aria-valuenow', '12')
    expect(screen.getByRole('progressbar', { name: 'Memory (RAM)' })).toHaveAttribute(
      'aria-valuenow',
      '96',
    )
    expect(screen.getByText('Memory is almost full.')).toBeInTheDocument()
    expect(screen.getByText('7.7 GB of 8 GB used')).toBeInTheDocument()
    expect(screen.getByText('Bluetooth is turned off.')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Turn on Bluetooth' })).toBeInTheDocument()
  })

  it('should list server services with uptime and connected clients', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue(reading())

    renderAppAt('/monitoring')

    const system = await systemSection()
    await system.findByText('Up 1h 30m')
    expect(system.getByText(/2 connected/)).toBeInTheDocument()
    expect(system.queryByText('Android services')).not.toBeInTheDocument()
  })

  it('should retry a failed part and show the attempt while it tries', async () => {
    const trying = reading({
      printer: { status: 'retrying', reason: undefined, retry: { attempt: 2, max: 3 } },
    })
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValueOnce(reading()).mockResolvedValue(trying)
    const retry = vi.spyOn(monitoringApi, 'retryService').mockResolvedValue(trying)
    renderAppAt('/monitoring')
    const clinic = await clinicSection()
    await clinic.findByRole('button', { name: 'Retry POS printer' })

    await userEvent.setup().click(clinic.getByRole('button', { name: 'Retry POS printer' }))

    expect(retry).toHaveBeenCalledWith('tok', 'printer')
    expect(await clinic.findByText('Attempt 2 of 3')).toBeInTheDocument()
    expect(clinic.queryByRole('button', { name: 'Retry POS printer' })).not.toBeInTheDocument()
  })

  it('should offer no retry for a part that is running', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockResolvedValue(reading())

    renderAppAt('/monitoring')

    const system = await systemSection()
    await system.findByRole('heading', { name: 'WebSockets' })
    expect(system.queryByRole('button', { name: 'Retry WebSockets' })).not.toBeInTheDocument()
    expect(system.queryByRole('button', { name: 'Retry Android services' })).not.toBeInTheDocument()
  })

  it('should say the page may be out of date when the tablet cannot be reached', async () => {
    vi.spyOn(monitoringApi, 'getMonitoring').mockRejectedValue(new Error('offline'))

    renderAppAt('/monitoring')

    expect(await screen.findByRole('alert')).toHaveTextContent(
      'The tablet could not be reached, so this page may be out of date.',
    )
    expect(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument()
  })
})
