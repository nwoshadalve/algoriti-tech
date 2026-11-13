/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { ConnectionGate } from '@/app/ConnectionGate'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { clearServerAddress, readServerAddress } from '@/core/serverAddress'

function renderGate() {
  return render(
    <LocaleProvider>
      <ConnectionGate>
        <p>dashboard</p>
      </ConnectionGate>
    </LocaleProvider>,
  )
}

describe('ConnectionGate', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
    clearServerAddress()
  })

  it('should show the app when the tablet answers', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: true }))
    renderGate()
    expect(await screen.findByText('dashboard')).toBeInTheDocument()
  })

  it('should ask for the IP address when the tablet name does not answer, then remember it', async () => {
    const reload = vi.fn()
    vi.stubGlobal('location', { ...window.location, reload })
    const fetchMock = vi.fn(async (url: string) => {
      if (url.startsWith('https://192.168.1.22:8443')) return { ok: true }
      throw new TypeError('Failed to fetch')
    })
    vi.stubGlobal('fetch', fetchMock)

    renderGate()
    const field = await screen.findByLabelText('Tablet IP address')
    await userEvent.type(field, '192.168.1.22')
    await userEvent.click(screen.getByRole('button', { name: 'Connect' }))

    await waitFor(() => expect(readServerAddress()).toBe('https://192.168.1.22:8443'))
    expect(reload).toHaveBeenCalled()
  })

  it('should not remember an address the tablet does not answer on', async () => {
    vi.stubGlobal('fetch', vi.fn().mockRejectedValue(new TypeError('Failed to fetch')))
    renderGate()
    await userEvent.type(await screen.findByLabelText('Tablet IP address'), '10.0.0.9')
    await userEvent.click(screen.getByRole('button', { name: 'Connect' }))

    expect(await screen.findByText('The tablet did not answer at that address.')).toBeInTheDocument()
    expect(readServerAddress()).toBeNull()
  })
})
