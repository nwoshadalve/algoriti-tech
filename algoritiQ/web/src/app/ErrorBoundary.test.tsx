/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import { ErrorBoundary } from '@/app/ErrorBoundary'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'

function Broken(): never {
  throw new Error('boom')
}

describe('ErrorBoundary', () => {
  afterEach(() => vi.restoreAllMocks())

  it('should show the error and a reload button when a page crashes', () => {
    vi.spyOn(console, 'error').mockImplementation(() => {})

    render(
      <LocaleProvider>
        <ErrorBoundary>
          <Broken />
        </ErrorBoundary>
      </LocaleProvider>,
    )

    expect(screen.getByRole('alert')).toHaveTextContent('Something went wrong')
    expect(screen.getByText('Error: boom')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Reload' })).toBeInTheDocument()
  })

  it('should render the app when nothing fails', () => {
    render(
      <LocaleProvider>
        <ErrorBoundary>
          <p>fine</p>
        </ErrorBoundary>
      </LocaleProvider>,
    )

    expect(screen.getByText('fine')).toBeInTheDocument()
  })
})
