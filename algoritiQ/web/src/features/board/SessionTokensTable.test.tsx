/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import { SessionTokensTable } from '@/features/board/SessionTokensTable'

function renderTable(embedded: boolean) {
  return render(
    <LocaleProvider>
      <ToastProvider>
        <SessionTokensTable
          tokens={[]}
          printerBusyTokenId={null}
          sort="serial"
          ascending
          onSort={vi.fn()}
          emptyFiltered={false}
          onClearFilters={vi.fn()}
          hasMore={false}
          isLoadingMore={false}
          onLoadMore={vi.fn()}
          onPrint={vi.fn()}
          onReprint={vi.fn()}
          onEditPatient={vi.fn()}
          onCancel={vi.fn()}
          embedded={embedded}
        />
      </ToastProvider>
    </LocaleProvider>,
  )
}

describe('SessionTokensTable scrolling on phones', () => {
  it.each([true, false])(
    'should not trap touch scrolling on small screens when embedded is %s',
    (embedded) => {
      renderTable(embedded)

      const scroller = screen.getByRole('table').parentElement as HTMLElement
      expect(scroller.className).toContain('max-md:overflow-visible')
      expect(scroller.className).toContain('max-md:overscroll-auto')
    },
  )
})

describe('SessionTokensTable on tablets', () => {
  it('should give the embedded table a fixed height so it scrolls inside itself', () => {
    renderTable(true)

    const scroller = screen.getByRole('table').parentElement as HTMLElement
    expect(scroller.className).toContain('overflow-y-auto')
    expect(scroller.className).toMatch(/md:h-\[/)
    expect(scroller.className).toContain('md:flex-none')
  })
})
