/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react'
import { getQueueDeskSnapshot } from '@/core/api/queueDesk'
import { getWorkScopes } from '@/core/api/workScope'
import type { AssignmentTarget, WorkScopeOption } from '@/core/api/workScope'
import { readSession } from '@/features/auth/session'
import { useAuth } from '@/features/auth/authContext'
import {
  WorkScopeContext,
  type WorkScopeState,
} from '@/features/work/workScopeContext'

/** The options whose chamber has a queue session open right now. */
async function activeOptionsOf(
  token: string,
  options: WorkScopeOption[],
): Promise<WorkScopeOption[]> {
  const checked = await Promise.all(
    options.map(async (option) => {
      const chamberId = option.deskChamberId ?? option.id
      try {
        const snapshot = await getQueueDeskSnapshot(token, chamberId, { includeTokens: false })
        return snapshot.sessionOpen ? option : null
      } catch {
        return null
      }
    }),
  )
  return checked.filter((option): option is WorkScopeOption => option !== null)
}

export function WorkScopeProvider({ children }: { children: ReactNode }) {
  const { state: auth } = useAuth()
  const [state, setState] = useState<WorkScopeState>({ status: 'idle' })
  const [options, setOptions] = useState<WorkScopeOption[] | null>(null)
  const [assignmentTarget, setAssignmentTarget] = useState<AssignmentTarget | null>(
    null,
  )
  const [assignmentCount, setAssignmentCount] = useState(0)

  useEffect(() => {
    if (auth.status !== 'signedIn' || auth.account.role !== 'receptionist') {
      setOptions(null)
      setAssignmentTarget(null)
      setAssignmentCount(0)
      setState({ status: 'idle' })
      return
    }

    const token = readSession()
    if (!token) {
      setState({ status: 'idle' })
      return
    }

    let cancelled = false
    setState({ status: 'loading' })
    void getWorkScopes(token).then(
      async (loaded) => {
        // With several chambers, go straight to the only one with a session running.
        const active =
          loaded.assignmentCount > 1 ? await activeOptionsOf(token, loaded.options) : []
        if (cancelled) return
        setOptions(loaded.options)
        setAssignmentTarget(loaded.assignmentTarget)
        setAssignmentCount(loaded.assignmentCount)
        setState(
          loaded.options.length === 0
            ? { status: 'unassigned' }
            : loaded.assignmentCount <= 1 || active.length === 1
              ? {
                  status: 'ready',
                  assignmentTarget: loaded.assignmentTarget,
                  options: loaded.options,
                  selected: active.length === 1 ? active[0]! : loaded.options[0]!,
                }
              : {
                  status: 'choose',
                  assignmentTarget: loaded.assignmentTarget,
                  options: loaded.options,
                },
        )
      },
      () => {
        if (!cancelled) setState({ status: 'unassigned' })
      },
    )
    return () => {
      cancelled = true
    }
  }, [auth])

  const select = useCallback(
    (option: WorkScopeOption) => {
      const target = assignmentTarget
      const list = options
      if (target == null || list == null) return
      setState({
        status: 'ready',
        assignmentTarget: target,
        options: list,
        selected: option,
      })
    },
    [assignmentTarget, options],
  )

  const reopenChoice = useCallback(() => {
    const list = options
    const target = assignmentTarget
    if (list == null || target == null || assignmentCount <= 1) return
    setState({ status: 'choose', assignmentTarget: target, options: list })
  }, [assignmentTarget, options, assignmentCount])

  const canChangeWorkScope = assignmentCount > 1

  const value = useMemo(
    () => ({ state, select, reopenChoice, canChangeWorkScope }),
    [state, select, reopenChoice, canChangeWorkScope],
  )

  return <WorkScopeContext.Provider value={value}>{children}</WorkScopeContext.Provider>
}
