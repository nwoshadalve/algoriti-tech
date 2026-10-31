/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import '@testing-library/jest-dom/vitest'
import { afterEach, vi } from 'vitest'

function installMatchMedia() {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
}

installMatchMedia()

/** Dashboard live channel tests open a WebSocket on sign-in routes. */
class MockWebSocket {
  static readonly OPEN = 1
  readonly url: string
  readyState = MockWebSocket.OPEN
  private listeners = new Map<string, Array<(event?: Event) => void>>()

  constructor(url: string) {
    this.url = url
    queueMicrotask(() => this.dispatch('open'))
  }

  addEventListener(type: string, listener: (event?: Event) => void) {
    const list = this.listeners.get(type) ?? []
    list.push(listener)
    this.listeners.set(type, list)
  }

  dispatch(type: string) {
    for (const listener of this.listeners.get(type) ?? []) {
      listener(new Event(type))
    }
  }

  close() {
    this.dispatch('close')
  }

  send(_data: string) {}
}

vi.stubGlobal('WebSocket', MockWebSocket)

/** `vi.restoreAllMocks()` in tests must not leave `matchMedia` broken. */
afterEach(() => {
  installMatchMedia()
})
