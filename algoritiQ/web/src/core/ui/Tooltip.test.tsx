/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { act, render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { PencilIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { Tooltip, TOOLTIP_DISMISS_EVENT } from '@/core/ui/Tooltip'

function setup(ui = <Tooltip label="Edit user"><button aria-label="Edit user">E</button></Tooltip>) {
  render(<LocaleProvider>{ui}</LocaleProvider>)
  return userEvent.setup({ advanceTimers: vi.advanceTimersByTime })
}

const tip = () => screen.queryByRole('tooltip', { hidden: true })

describe('Tooltip', () => {
  beforeEach(() => vi.useFakeTimers({ shouldAdvanceTime: true }))
  afterEach(() => vi.useRealTimers())

  it('should wait a moment on hover, then show the words', async () => {
    const user = setup()

    await user.hover(screen.getByRole('button', { name: 'Edit user' }))
    expect(tip()).toBeNull()
    act(() => {
      vi.advanceTimersByTime(400)
    })

    expect(tip()).toHaveTextContent('Edit user')
  })

  it('should show at once on keyboard focus and hide when focus leaves', async () => {
    const user = setup()

    await user.tab()
    expect(tip()).toHaveTextContent('Edit user')
    await user.tab()

    expect(tip()).toBeNull()
  })

  it('should hide on Escape, on leaving and on click', async () => {
    const user = setup()
    const button = screen.getByRole('button', { name: 'Edit user' })

    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    await user.keyboard('{Escape}')
    expect(tip()).toBeNull()

    await user.unhover(button)
    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    await user.unhover(button)
    expect(tip()).toBeNull()

    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    await user.click(button)
    expect(tip()).toBeNull()
  })

  it('should stay hidden after click until the pointer leaves the control', async () => {
    const user = setup()
    const button = screen.getByRole('button', { name: 'Edit user' })

    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    expect(tip()).toHaveTextContent('Edit user')

    await user.click(button)
    expect(tip()).toBeNull()

    act(() => {
      vi.advanceTimersByTime(1000)
    })
    expect(tip()).toBeNull()

    await user.unhover(button)
    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    expect(tip()).toHaveTextContent('Edit user')
  })

  it('should hide when the app opens a modal', async () => {
    setup()
    const button = screen.getByRole('button', { name: 'Edit user' })
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime })

    await user.hover(button)
    act(() => {
      vi.advanceTimersByTime(400)
    })
    expect(tip()).toHaveTextContent('Edit user')

    act(() => {
      document.dispatchEvent(new Event(TOOLTIP_DISMISS_EVENT))
    })
    expect(tip()).toBeNull()
  })

  it('should not show if the pointer leaves before the pause is over', async () => {
    const user = setup()
    const button = screen.getByRole('button', { name: 'Edit user' })

    await user.hover(button)
    await user.unhover(button)
    act(() => {
      vi.advanceTimersByTime(1000)
    })

    expect(tip()).toBeNull()
  })

  it('should be left out of what a screen reader reads', async () => {
    const user = setup()
    await user.tab()

    expect(tip()).toHaveAttribute('aria-hidden', 'true')
    expect(screen.getAllByRole('button', { name: 'Edit user' })).toHaveLength(1)
  })
})

describe('IconButton', () => {
  beforeEach(() => vi.useFakeTimers({ shouldAdvanceTime: true }))
  afterEach(() => vi.useRealTimers())

  it('should be named by its action and run it on click', async () => {
    const onClick = vi.fn()
    const user = setup(<IconButton label="Edit" icon={PencilIcon} onClick={onClick} />)

    await user.click(screen.getByRole('button', { name: 'Edit' }))

    expect(onClick).toHaveBeenCalledTimes(1)
  })

  it('should take a fuller accessible name than its tooltip', async () => {
    const user = setup(<IconButton label="Edit" ariaLabel="Edit: Dr. Rahim" icon={PencilIcon} />)

    await user.tab()

    expect(screen.getByRole('button', { name: 'Edit: Dr. Rahim' })).toBeInTheDocument()
    expect(tip()).toHaveTextContent('Edit')
  })

  it('should say why it is disabled, in its tooltip', async () => {
    const onClick = vi.fn()
    const user = setup(
      <IconButton label="Add" icon={PencilIcon} disabled disabledReason="No room left" onClick={onClick} />,
    )
    const button = screen.getByRole('button', { name: 'Add' })

    expect(button).toBeDisabled()
    await user.hover(button.parentElement as HTMLElement)
    act(() => {
      vi.advanceTimersByTime(400)
    })

    expect(tip()).toHaveTextContent('No room left')
    await user.click(button)
    expect(onClick).not.toHaveBeenCalled()
  })

  it('should show its label beside the icon below md, where there is no hover', () => {
    setup(<IconButton label="Disable" icon={PencilIcon} labelOnSmall />)

    const button = screen.getByRole('button', { name: 'Disable' })

    expect(button).toHaveTextContent('Disable')
    expect(button.querySelector('span')?.className).toContain('md:hidden')
  })
})
