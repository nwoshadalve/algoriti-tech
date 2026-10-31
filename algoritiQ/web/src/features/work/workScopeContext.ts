/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { createContext, useContext } from 'react'
import type { AssignmentTarget, WorkScopeOption } from '@/core/api/workScope'

export type WorkScopeState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'unassigned' }
  | {
      status: 'choose'
      assignmentTarget: AssignmentTarget
      options: WorkScopeOption[]
    }
  | {
      status: 'ready'
      assignmentTarget: AssignmentTarget
      options: WorkScopeOption[]
      selected: WorkScopeOption
    }

export type WorkScopeContextValue = {
  state: WorkScopeState
  select: (option: WorkScopeOption) => void
  reopenChoice: () => void
  canChangeWorkScope: boolean
}

export const WorkScopeContext = createContext<WorkScopeContextValue | null>(null)

export function useWorkScope(): WorkScopeContextValue {
  const value = useContext(WorkScopeContext)
  if (!value) throw new Error('useWorkScope must be used within WorkScopeProvider')
  return value
}

/** True when the receptionist must pick or is blocked for missing scopes. */
export function workScopeBlocksDashboard(state: WorkScopeState): boolean {
  return (
    state.status === 'loading' ||
    state.status === 'unassigned' ||
    state.status === 'choose'
  )
}
