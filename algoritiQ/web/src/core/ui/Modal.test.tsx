/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { useState } from 'react'
import { describe, expect, it, vi } from 'vitest'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { Modal } from '@/core/ui/Modal'

function Harness({
  busy = false,
  footer = true,
  onClose = vi.fn(),
}: {
  busy?: boolean
  footer?: boolean
  onClose?: () => void
}) {
  const [open, setOpen] = useState(false)
  return (
    <LocaleProvider>
      <button onClick={() => setOpen(true)}>open it</button>
      {open ? (
        <Modal
          title="Edit things"
          description="Change what you need."
          busy={busy}
          onClose={() => {
            onClose()
            setOpen(false)
          }}
          footer={footer ? <button>Save it</button> : undefined}
        >
          <input aria-label="first" />
          <input aria-label="second" />
        </Modal>
      ) : null}
    </LocaleProvider>
  )
}

async function openIt(props: Parameters<typeof Harness>[0] = {}) {
  render(<Harness {...props} />)
  const user = userEvent.setup()
  await user.click(screen.getByRole('button', { name: 'open it' }))
  return { user, dialog: screen.getByRole('dialog', { name: 'Edit things' }) }
}

describe('Modal', () => {
  it('should be a labelled, described, modal dialog', async () => {
    const { dialog } = await openIt()

    expect(dialog).toHaveAttribute('aria-modal', 'true')
    expect(dialog).toHaveAccessibleDescription('Change what you need.')
  })

  it('should keep the header and footer outside the scrolling body', async () => {
    const { dialog } = await openIt()
    const body = within(dialog).getByTestId('modal-body')

    expect(body.className).toContain('overflow-y-auto')
    expect(body).toContainElement(within(dialog).getByLabelText('first'))
    expect(body).not.toContainElement(within(dialog).getByRole('heading', { name: 'Edit things' }))
    expect(body).not.toContainElement(within(dialog).getByRole('button', { name: 'Save it' }))
    expect(within(dialog).getByRole('banner')).toBeInTheDocument()
    expect(within(dialog).getByRole('contentinfo')).toContainElement(
      within(dialog).getByRole('button', { name: 'Save it' }),
    )
  })

  it('should leave the footer out when there is none', async () => {
    const { dialog } = await openIt({ footer: false })

    expect(within(dialog).queryByRole('contentinfo')).toBeNull()
  })

  it('should hold the page still while open and release it after', async () => {
    const { user } = await openIt()
    expect(document.body.classList.contains('overflow-hidden')).toBe(true)

    await user.keyboard('{Escape}')

    expect(document.body.classList.contains('overflow-hidden')).toBe(false)
  })

  it('should focus the first field and give focus back to the opener', async () => {
    const { user, dialog } = await openIt()
    expect(within(dialog).getByLabelText('first')).toHaveFocus()

    await user.keyboard('{Escape}')

    expect(screen.getByRole('button', { name: 'open it' })).toHaveFocus()
  })

  it('should keep Tab inside', async () => {
    const { user, dialog } = await openIt()

    // first -> second -> Save it -> (wraps) Close -> first ...
    await user.tab()
    await user.tab()
    expect(within(dialog).getByRole('button', { name: 'Save it' })).toHaveFocus()
    await user.tab()
    expect(within(dialog).getByRole('button', { name: 'Close' })).toHaveFocus()
    await user.tab({ shift: true })
    expect(within(dialog).getByRole('button', { name: 'Save it' })).toHaveFocus()
  })

  it('should close with the X button, Escape and a press on the dark area', async () => {
    const onClose = vi.fn()
    render(<Harness onClose={onClose} />)
    const user = userEvent.setup()

    await user.click(screen.getByRole('button', { name: 'open it' }))
    await user.click(screen.getByRole('button', { name: 'Close' }))
    await user.click(screen.getByRole('button', { name: 'open it' }))
    await user.keyboard('{Escape}')
    await user.click(screen.getByRole('button', { name: 'open it' }))
    await user.pointer({
      keys: '[MouseLeft]',
      target: screen.getByRole('dialog').parentElement as HTMLElement,
    })

    expect(onClose).toHaveBeenCalledTimes(3)
  })

  it('should not close from a press inside the popup', async () => {
    const onClose = vi.fn()
    const { user, dialog } = await openIt({ onClose })

    await user.click(within(dialog).getByLabelText('second'))

    expect(onClose).not.toHaveBeenCalled()
  })

  it('should not close while busy and should hide the close control', async () => {
    const onClose = vi.fn()
    const { user, dialog } = await openIt({ busy: true, onClose })

    await user.keyboard('{Escape}')
    await user.pointer({ keys: '[MouseLeft]', target: dialog.parentElement as HTMLElement })

    expect(onClose).not.toHaveBeenCalled()
    expect(within(dialog).queryByRole('button', { name: 'Close' })).toBeNull()
  })
})
