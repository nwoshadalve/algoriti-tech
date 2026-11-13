/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import * as feeCodesApi from '@/core/api/feeCodes'
import { LocaleProvider } from '@/core/i18n/LocaleProvider'
import { ToastProvider } from '@/core/toast/ToastProvider'
import * as session from '@/features/auth/session'
import { FeeCodesCard } from '@/features/fees/FeeCodesCard'
import { parseFeeAmount, validateFeeRows } from '@/features/fees/feeCodesValidation'

function renderCard() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={client}>
      <LocaleProvider>
        <ToastProvider>
          <FeeCodesCard />
        </ToastProvider>
      </LocaleProvider>
    </QueryClientProvider>,
  )
}

const save = () => screen.getByRole('button', { name: 'Save fee codes' })

describe('FeeCodesCard', () => {
  beforeEach(() => {
    vi.spyOn(session, 'readSession').mockReturnValue('token')
  })
  afterEach(() => vi.restoreAllMocks())

  it('should say the fee is typed by hand while there are no codes', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([])
    renderCard()

    expect(await screen.findByText(/No fee codes yet/)).toBeInTheDocument()
    expect(save()).toBeDisabled()
  })

  it('should show the saved codes', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([
      { id: 'a', code: 'NEW', amountBdt: 500 },
    ])
    renderCard()

    expect(await screen.findByDisplayValue('NEW')).toBeInTheDocument()
    expect(screen.getByDisplayValue('500')).toBeInTheDocument()
  })

  it('should add a code and save it', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([])
    const saveApi = vi
      .spyOn(feeCodesApi, 'saveFeeCodes')
      .mockResolvedValue([{ id: 'x', code: 'NEW', amountBdt: 500 }])
    renderCard()
    await screen.findByText(/No fee codes yet/)

    fireEvent.click(screen.getByRole('button', { name: 'Add fee code' }))
    fireEvent.change(screen.getByLabelText('Code'), { target: { value: ' NEW ' } })
    fireEvent.change(screen.getByLabelText('Amount (BDT)'), { target: { value: '500' } })
    fireEvent.click(save())

    await waitFor(() =>
      expect(saveApi).toHaveBeenCalledWith('token', [{ code: 'NEW', amountBdt: 500 }]),
    )
    expect(await screen.findByDisplayValue('NEW')).toBeInTheDocument()
    await waitFor(() => expect(save()).toBeDisabled())
  })

  it('should keep the id of a code that is edited', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([
      { id: 'a', code: 'NEW', amountBdt: 500 },
    ])
    const saveApi = vi
      .spyOn(feeCodesApi, 'saveFeeCodes')
      .mockResolvedValue([{ id: 'a', code: 'NEW', amountBdt: 600 }])
    renderCard()

    fireEvent.change(await screen.findByDisplayValue('500'), { target: { value: '600' } })
    fireEvent.click(save())

    await waitFor(() =>
      expect(saveApi).toHaveBeenCalledWith('token', [{ id: 'a', code: 'NEW', amountBdt: 600 }]),
    )
  })

  it('should not save a repeated code or a bad amount, and say why', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([
      { id: 'a', code: 'NEW', amountBdt: 500 },
    ])
    const saveApi = vi.spyOn(feeCodesApi, 'saveFeeCodes')
    renderCard()
    await screen.findByDisplayValue('NEW')

    fireEvent.click(screen.getByRole('button', { name: 'Add fee code' }))
    fireEvent.change(screen.getAllByLabelText('Code')[1], { target: { value: 'new' } })
    fireEvent.change(screen.getAllByLabelText('Amount (BDT)')[1], { target: { value: '0' } })
    fireEvent.click(save())

    expect(await screen.findByText('Another row has this code.')).toBeInTheDocument()
    expect(saveApi).not.toHaveBeenCalled()
  })

  it('should remove a code and save the shorter list, down to none', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([
      { id: 'a', code: 'NEW', amountBdt: 500 },
    ])
    const saveApi = vi.spyOn(feeCodesApi, 'saveFeeCodes').mockResolvedValue([])
    renderCard()
    await screen.findByDisplayValue('NEW')

    fireEvent.click(screen.getByRole('button', { name: 'Remove fee code 1' }))
    fireEvent.click(save())

    await waitFor(() => expect(saveApi).toHaveBeenCalledWith('token', []))
    expect(await screen.findByText(/No fee codes yet/)).toBeInTheDocument()
  })

  it('should discard what was edited', async () => {
    vi.spyOn(feeCodesApi, 'getFeeCodes').mockResolvedValue([
      { id: 'a', code: 'NEW', amountBdt: 500 },
    ])
    renderCard()
    fireEvent.change(await screen.findByDisplayValue('500'), { target: { value: '999' } })

    fireEvent.click(screen.getByRole('button', { name: 'Discard changes' }))

    expect(screen.getByDisplayValue('500')).toBeInTheDocument()
    expect(save()).toBeDisabled()
  })
})

describe('fee code rules', () => {
  const row = (key: string, code: string, amount: string) => ({ key, id: '', code, amount })

  it('should accept only whole amounts from 1 to the limit', () => {
    expect(parseFeeAmount('500')).toBe(500)
    expect(parseFeeAmount(' 7 ')).toBe(7)
    for (const bad of ['', '0', '-5', '1.5', '12a', '10000000']) {
      expect(parseFeeAmount(bad), bad).toBeNull()
    }
  })

  it('should find an empty code, a repeat (any case) and a bad amount', () => {
    const errors = validateFeeRows([
      row('1', 'NEW', '500'),
      row('2', 'new', '300'),
      row('3', ' ', '300'),
      row('4', 'OTHER', 'x'),
    ])

    expect(errors.get('1')).toBeUndefined()
    expect(errors.get('2')).toBe('codeDuplicate')
    expect(errors.get('3')).toBe('codeRequired')
    expect(errors.get('4')).toBe('amountInvalid')
  })
})
