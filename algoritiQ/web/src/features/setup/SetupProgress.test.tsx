/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { SetupProgress } from '@/features/setup/SetupProgress'
import { renderWithRouter } from '@/test/render'

describe('SetupProgress', () => {
  it('should say which step of three the visitor is on', () => {
    renderWithRouter(<SetupProgress activeStep={2} />)

    expect(screen.getByRole('group', { name: 'Setup progress' })).toBeInTheDocument()
    expect(
      screen.getByText(/Step 2 of 3/, { selector: 'p' }),
    ).toHaveTextContent('Enter the activation code from the tablet')
  })

  it('should name the last step on the registration page', () => {
    renderWithRouter(<SetupProgress activeStep={3} />)

    expect(screen.getByText(/Step 3 of 3/, { selector: 'p' })).toHaveTextContent(
      'Create the administrator account, then sign in',
    )
  })

  it('should be shown below the wide layout only', () => {
    renderWithRouter(<SetupProgress activeStep={1} />)

    expect(screen.getByRole('group', { name: 'Setup progress' }).className).toContain('lg:hidden')
  })

  it('should follow the language', () => {
    localStorage.setItem('algoritiq.locale', 'bn')

    renderWithRouter(<SetupProgress activeStep={2} />)

    expect(screen.getByRole('group', { name: 'সেটআপের অগ্রগতি' })).toBeInTheDocument()
    expect(screen.getByText(/ধাপ 2 \/ 3/, { selector: 'p' })).toBeInTheDocument()
    localStorage.removeItem('algoritiq.locale')
  })
})
