/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react'
import {
  parseLiveFrame,
  pongFrame,
  resolveLiveWebSocketUrl,
  type LiveConnectionState,
} from '@/core/api/live'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'

type LiveChannelValue = {
  state: LiveConnectionState
  lastEventSequence: number | null
  /** Reconnect tries since the last good connection (0 while connected). */
  attempt: number
  /** Connects again now instead of waiting for the next automatic try. */
  retry: () => void
}

const LiveChannelContext = createContext<LiveChannelValue | null>(null)

const maxBackoffMs = 30_000

/** Maintains the live WebSocket while the user is signed in. */
export function LiveChannelProvider({ children }: { children: ReactNode }) {
  const { state: authState } = useAuth()
  const [liveState, setLiveState] = useState<LiveConnectionState>('idle')
  const [lastEventSequence, setLastEventSequence] = useState<number | null>(null)
  const [attempt, setAttempt] = useState(0)
  const retryNowRef = useRef<() => void>(() => {})
  const socketRef = useRef<WebSocket | null>(null)
  const attemptRef = useRef(0)
  const closedRef = useRef(false)

  const signedIn = authState.status === 'signedIn'

  const disconnect = useCallback(() => {
    closedRef.current = true
    socketRef.current?.close()
    socketRef.current = null
    setLiveState('idle')
  }, [])

  useEffect(() => {
    if (!signedIn) {
      disconnect()
      return
    }

    closedRef.current = false
    attemptRef.current = 0
    let retryTimer: ReturnType<typeof setTimeout> | undefined

    function scheduleReconnect() {
      if (closedRef.current) return
      const tries = attemptRef.current
      attemptRef.current = tries + 1
      setAttempt(tries + 1)
      const delay = Math.min(maxBackoffMs, 500 * 2 ** tries)
      setLiveState('offline')
      retryTimer = setTimeout(connect, delay)
    }

    function connect() {
      if (closedRef.current) return
      const token = readSession()
      if (!token) {
        setLiveState('offline')
        return
      }

      setLiveState('connecting')
      let socket: WebSocket
      try {
        socket = new WebSocket(resolveLiveWebSocketUrl(token))
      } catch {
        // Some browsers throw (e.g. the CSP does not cover wss): stay usable, show offline.
        scheduleReconnect()
        return
      }
      socketRef.current = socket

      socket.addEventListener('open', () => {
        attemptRef.current = 0
        setAttempt(0)
        setLiveState('connected')
      })

      socket.addEventListener('message', (event) => {
        const frame = parseLiveFrame(String(event.data))
        if (!frame) return
        if ('eventSequence' in frame && typeof frame.eventSequence === 'number') {
          setLastEventSequence(frame.eventSequence)
        }
        if (frame.type === 'ping') {
          socket.send(pongFrame())
        }
      })

      socket.addEventListener('close', () => {
        socketRef.current = null
        if (!closedRef.current) scheduleReconnect()
      })

      socket.addEventListener('error', () => {
        socket.close()
      })
    }

    retryNowRef.current = () => {
      // Only when waiting for the next try: a socket still connecting is already trying.
      if (socketRef.current) return
      if (retryTimer) clearTimeout(retryTimer)
      connect()
    }
    connect()

    return () => {
      closedRef.current = true
      if (retryTimer) clearTimeout(retryTimer)
      socketRef.current?.close()
      socketRef.current = null
      setLiveState('idle')
    }
  }, [signedIn, disconnect])

  const retry = useCallback(() => retryNowRef.current(), [])
  const value = useMemo(
    () => ({ state: liveState, lastEventSequence, attempt, retry }),
    [liveState, lastEventSequence, attempt, retry],
  )

  return <LiveChannelContext.Provider value={value}>{children}</LiveChannelContext.Provider>
}

export function useLiveChannel(): LiveChannelValue {
  const ctx = useContext(LiveChannelContext)
  if (!ctx) {
    throw new Error('useLiveChannel must be used within LiveChannelProvider')
  }
  return ctx
}

/** Maps live channel state to the dashboard connection chip. */
export function liveStateToHealth(
  live: LiveConnectionState,
): 'connected' | 'checking' | 'offline' {
  if (live === 'connected') return 'connected'
  if (live === 'connecting' || live === 'idle') return 'checking'
  return 'offline'
}
