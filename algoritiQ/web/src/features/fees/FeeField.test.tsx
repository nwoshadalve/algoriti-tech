/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { useState } from 'react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as feeCodesApi from '@/core/api/feeCodes'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import * as session from '@/features/auth/session'
import { FeeField } from '@/features/fees/FeeField'

const codes = [
  { id: 'a', code: 'NEW', amountBdt: 500 },
  { id: 'b', code: 'FOLLOW', amountBdt: 300 },
]

function Harness({ initial = '' }: { initial?: string }) {
  const [value, setValue] = useState(initial)
  return (
    <>
      <FeeField id="fee" value={value} onChange={setValue} />
      <output data-testid="amount">{value}</output>
    </>
  )
}

function renderField(initial?: string) {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={client}>
      <LocaleProvider>
        <Harness initial={initial} />
      </LocaleProvider>
    </QueryClientProvider>,
  )
}

describe('FeeField', () => {
  beforeEach(() => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
  })
  afterEach(() => vi.restoreAllMocks())

  it('should be the free amount field while no codes are defined', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([])
    renderField()

    fireEvent.change(await screen.findByRole('textbox'), { target: { value: '450' } })

    expect(screen.queryByRole('combobox')).not.toBeInTheDocument()
    expect(screen.getByTestId('amount')).toHaveTextContent('450')
  })

  it('should stay the free field when the tablet cannot list codes', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockRejectedValue(new Error('not_found'))
    renderField()

    expect(await screen.findByRole('textbox')).toBeInTheDocument()
  })

  it('should start on "No fee" when codes exist', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue(codes)
    renderField()

    const select = (await screen.findByRole('combobox')) as HTMLSelectElement

    expect(select.selectedOptions[0]).toHaveTextContent('No fee')
    expect(screen.getByTestId('amount')).toBeEmptyDOMElement()
    expect(screen.queryByRole('textbox')).not.toBeInTheDocument()
  })

  it('should list the codes with their amounts and fill in the one chosen', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue(codes)
    renderField()
    const select = await screen.findByRole('combobox')

    expect(screen.getByRole('option', { name: 'NEW — 500' })).toBeInTheDocument()
    expect(screen.getByRole('option', { name: 'FOLLOW — 300' })).toBeInTheDocument()
    fireEvent.change(select, { target: { value: 'a' } })

    expect(screen.getByTestId('amount')).toHaveTextContent('500')
  })

  it('should clear the fee when "No fee" is chosen again', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue(codes)
    renderField('300')
    const select = (await screen.findByRole('combobox')) as HTMLSelectElement
    expect(select.selectedOptions[0]).toHaveTextContent('FOLLOW — 300')

    fireEvent.change(select, { target: { value: '' } })

    expect(screen.getByTestId('amount')).toBeEmptyDOMElement()
  })

  it('should keep a fee that matches no code', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue(codes)
    renderField('725')
    const select = (await screen.findByRole('combobox')) as HTMLSelectElement

    expect(select.selectedOptions[0]).toHaveTextContent('725')
    expect(screen.getByTestId('amount')).toHaveTextContent('725')
  })
})
