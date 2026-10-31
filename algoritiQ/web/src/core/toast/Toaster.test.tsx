/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { act, render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ThemeProvider } from '@/core/theme/ThemeProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import { MAX_TOASTS, useToast } from '@/core/toast/toastContext'

function Buttons() {
  const toast = useToast()
  return (
    <>
      <button onClick={() => toast.success('Saved it')}>ok</button>
      <button onClick={() => toast.error('It broke')}>bad</button>
      <button
        onClick={() => {
          for (let i = 1; i <= 7; i++) toast.success(`Message ${i}`)
        }}
      >
        many
      </button>
    </>
  )
}

function setup() {
  render(
    <ThemeProvider>
      <LocaleProvider>
        <ToastProvider>
          <Buttons />
        </ToastProvider>
      </LocaleProvider>
    </ThemeProvider>,
  )
  return userEvent.setup({ advanceTimers: vi.advanceTimersByTime })
}

const region = () => screen.getByLabelText('Notifications')

describe('toaster', () => {
  beforeEach(() => vi.useFakeTimers({ shouldAdvanceTime: true }))
  afterEach(() => vi.useRealTimers())

  it('should show a success toast without an alert role', async () => {
    const user = setup()

    await user.click(screen.getByRole('button', { name: 'ok' }))

    expect(within(region()).getByText('Saved it')).toBeInTheDocument()
    expect(screen.queryByRole('alert')).toBeNull()
  })

  it('should announce a failure as an alert', async () => {
    const user = setup()

    await user.click(screen.getByRole('button', { name: 'bad' }))

    expect(screen.getByRole('alert')).toHaveTextContent('It broke')
  })

  it('should keep at most five toasts and drop the oldest', async () => {
    const user = setup()

    await user.click(screen.getByRole('button', { name: 'many' }))

    expect(MAX_TOASTS).toBe(5)
    expect(within(region()).getAllByRole('button', { name: 'Dismiss notification' })).toHaveLength(5)
    expect(screen.queryByText('Message 1')).toBeNull()
    expect(screen.queryByText('Message 2')).toBeNull()
    expect(screen.getByText('Message 3')).toBeInTheDocument()
    expect(screen.getByText('Message 7')).toBeInTheDocument()
  })

  it('should show the same message once, not stacked', async () => {
    const user = setup()

    await user.click(screen.getByRole('button', { name: 'bad' }))
    await user.click(screen.getByRole('button', { name: 'bad' }))
    await user.click(screen.getByRole('button', { name: 'bad' }))

    expect(screen.getAllByText('It broke')).toHaveLength(1)
  })

  it('should go away by itself, failures later than successes', async () => {
    const user = setup()
    await user.click(screen.getByRole('button', { name: 'ok' }))
    await user.click(screen.getByRole('button', { name: 'bad' }))

    act(() => {
      vi.advanceTimersByTime(4600)
    })
    expect(screen.queryByText('Saved it')).toBeNull()
    expect(screen.getByText('It broke')).toBeInTheDocument()

    act(() => {
      vi.advanceTimersByTime(3600)
    })
    expect(screen.queryByText('It broke')).toBeNull()
  })

  it('should restart the countdown when the same message comes again', async () => {
    const user = setup()
    await user.click(screen.getByRole('button', { name: 'ok' }))
    act(() => {
      vi.advanceTimersByTime(3500)
    })

    await user.click(screen.getByRole('button', { name: 'ok' }))
    act(() => {
      vi.advanceTimersByTime(3500)
    })

    expect(screen.getByText('Saved it')).toBeInTheDocument()
  })

  it('should wait while the pointer is over it', async () => {
    const user = setup()
    await user.click(screen.getByRole('button', { name: 'ok' }))
    const toast = screen.getByText('Saved it').closest('[data-tone]') as HTMLElement

    await user.hover(toast)
    act(() => {
      vi.advanceTimersByTime(20_000)
    })
    expect(screen.getByText('Saved it')).toBeInTheDocument()

    await user.unhover(toast)
    act(() => {
      vi.advanceTimersByTime(4600)
    })
    expect(screen.queryByText('Saved it')).toBeNull()
  })

  it('should close with its button', async () => {
    const user = setup()
    await user.click(screen.getByRole('button', { name: 'ok' }))

    await user.click(within(region()).getByRole('button', { name: 'Dismiss notification' }))

    expect(screen.queryByText('Saved it')).toBeNull()
  })
})
