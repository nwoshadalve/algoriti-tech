/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

export type LiveEventHandler = (name: string, payload: Record<string, unknown>) => void

const handlers = new Set<LiveEventHandler>()

/** Called by [LiveChannelProvider] for each `event` frame. */
export function dispatchLiveEvent(name: string, payload: Record<string, unknown>) {
  for (const handler of handlers) handler(name, payload)
}

export function subscribeLiveEvent(handler: LiveEventHandler): () => void {
  handlers.add(handler)
  return () => handlers.delete(handler)
}
