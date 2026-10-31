/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState } from 'react'
import { getMonitoring, retryService, type Monitoring, type ServiceId } from '@/core/api/monitoring'
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
}

/** Keeps the tablet's health reading fresh: every few seconds, faster while a retry runs. */
export function useMonitoring(): MonitoringState {
  const [data, setData] = useState<Monitoring | null>(null)
  const [failed, setFailed] = useState(false)
  const [reloads, setReloads] = useState(0)
  const retrying = data?.services.some((s) => s.status === 'retrying') ?? false

  useEffect(() => {
    const token = readSession()
    if (!token) return
    const controller = new AbortController()
    let timer: ReturnType<typeof setTimeout> | undefined

    async function load(signedIn: string) {
      try {
        const next = await getMonitoring(signedIn, controller.signal)
        setData(next)
        setFailed(false)
      } catch {
        if (controller.signal.aborted) return
        setFailed(true)
      }
      if (!controller.signal.aborted) {
        timer = setTimeout(() => void load(signedIn), retrying ? fastPollMs : slowPollMs)
      }
    }

    void load(token)
    return () => {
      controller.abort()
      if (timer) clearTimeout(timer)
    }
  }, [retrying, reloads])

  const retry = useCallback(async (id: ServiceId) => {
    const token = readSession()
    if (!token) return
    try {
      setData(await retryService(token, id))
      setFailed(false)
    } catch {
      setFailed(true)
    }
  }, [])

  const reload = useCallback(() => setReloads((n) => n + 1), [])

  return { data, failed, retry, reload }
}
