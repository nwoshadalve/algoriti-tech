import { describe, expect, it } from 'vitest'
import { render, screen } from '@testing-library/react'
import { BrandLoader } from '@/core/ui/BrandLoader'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ThemeProvider } from '@/core/theme/ThemeProvider'

describe('BrandLoader', () => {
  it('should expose a loading status for assistive tech', () => {
    render(
      <ThemeProvider>
        <LocaleProvider>
          <BrandLoader semanticLabel="Loading…" />
        </LocaleProvider>
      </ThemeProvider>,
    )

    expect(screen.getByRole('status', { name: 'Loading…' })).toBeInTheDocument()
  })
})
