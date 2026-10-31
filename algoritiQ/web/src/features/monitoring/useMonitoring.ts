/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useCallback, useState } from 'react'
import {
  enableBluetooth,
  getMonitoring,
  retryService,
  testPrinter,
  type BluetoothEnableOutcome,
  type Monitoring,
  type PrinterTestOutcome,
  type ServiceId,
} from '@/core/api/monitoring'
import { monitoringQueryKeys } from '@/features/monitoring/monitoringQueryKeys'
import { readSession } from '@/features/auth/session'

const slowPollMs = 5_000
/** While a retry runs, so its attempts show as they happen. */
const fastPollMs = 1_000

export type MonitoringState = {
  data: Monitoring | null
  /** The last reading could not be fetched; `data` may be old or null. */
  failed: boolean
  /** Asks the tablet to try a part again; the next readings show the progress. */
  retry: (id: ServiceId) => Promise<void>
  /** Reads again now (after a failed first load). */
  reload: () => void
  /** Asks the tablet to turn Bluetooth on (confirm on the tablet screen). */
  turnBluetoothOn: () => Promise<BluetoothEnableOutcome | null>
  /** True while waiting for the tablet after turnBluetoothOn. */
  bluetoothBusy: boolean
  /** Sends a test token to the POS printer; returns the outcome or null on failure. */
  testPrint: () => Promise<PrinterTestOutcome | null>
  testPrintBusy: boolean
}

function requireSessionToken(): string {
  const token = readSession()
  if (!token) throw new Error('signed_out')
  return token
}

/** Keeps the tablet's health reading fresh: every few seconds, faster while a retry runs. */
export function useMonitoring(): MonitoringState {
  const queryClient = useQueryClient()
  const [actionFailed, setActionFailed] = useState(false)

  const snapshotQuery = useQuery({
    queryKey: monitoringQueryKeys.snapshot(),
    queryFn: ({ signal }) => getMonitoring(requireSessionToken(), signal),
    retry: false,
    refetchInterval: (query) => {
      const retrying =
        query.state.data?.services.some((service) => service.status === 'retrying') ?? false
      return retrying ? fastPollMs : slowPollMs
    },
    refetchIntervalInBackground: false,
  })

  const setSnapshot = useCallback(
    (next: Monitoring) => {
      queryClient.setQueryData(monitoringQueryKeys.snapshot(), next)
      setActionFailed(false)
    },
    [queryClient],
  )

  const retryMutation = useMutation({
    mutationFn: async (id: ServiceId) => retryService(requireSessionToken(), id),
    onSuccess: setSnapshot,
    onError: () => setActionFailed(true),
  })

  const bluetoothMutation = useMutation({
    mutationFn: async () => enableBluetooth(requireSessionToken()),
    onSuccess: (result) => setSnapshot(result),
    onError: () => setActionFailed(true),
  })

  const testPrintMutation = useMutation({
    mutationFn: async () => testPrinter(requireSessionToken()),
    onSuccess: (result) => setSnapshot(result),
    onError: () => setActionFailed(true),
  })

  const retry = useCallback(
    async (id: ServiceId) => {
      await retryMutation.mutateAsync(id)
    },
    [retryMutation],
  )

  const reload = useCallback(() => {
    setActionFailed(false)
    void snapshotQuery.refetch()
  }, [snapshotQuery])

  const turnBluetoothOn = useCallback(async () => {
    if (bluetoothMutation.isPending) return null
    try {
      const result = await bluetoothMutation.mutateAsync()
      return result.outcome
    } catch {
      return null
    }
  }, [bluetoothMutation])

  const testPrint = useCallback(async () => {
    if (testPrintMutation.isPending) return null
    try {
      const result = await testPrintMutation.mutateAsync()
      return result.outcome
    } catch {
      return null
    }
  }, [testPrintMutation])

  const data = snapshotQuery.data ?? null
  const failed =
    actionFailed ||
    snapshotQuery.isError ||
    snapshotQuery.isRefetchError

  return {
    data,
    failed,
    retry,
    reload,
    turnBluetoothOn,
    bluetoothBusy: bluetoothMutation.isPending,
    testPrint,
    testPrintBusy: testPrintMutation.isPending,
  }
}
