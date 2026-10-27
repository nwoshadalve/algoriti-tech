import { config } from '@/core/config'
import type { ApiErrorBody } from '@/core/api/types'

export class ApiError extends Error {
  readonly code: string
  readonly attemptsLeft?: number
  /** From the `Retry-After` header of a 429 answer. */
  readonly retryAfterSeconds?: number

  constructor(code: string, message: string, attemptsLeft?: number, retryAfterSeconds?: number) {
    super(message)
    this.name = 'ApiError'
    this.code = code
    this.attemptsLeft = attemptsLeft
    this.retryAfterSeconds = retryAfterSeconds
  }
}

/** `Authorization` header for a signed-in call. */
export function bearer(token: string): HeadersInit {
  return { Authorization: `Bearer ${token}` }
}

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const headers = new Headers(init?.headers)
  if (init?.body && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const response = await fetch(`${config.apiBasePath}${path}`, {
    ...init,
    headers,
  })

  if (response.status === 204) {
    return undefined as T
  }

  const text = await response.text()
  const payload = text ? (JSON.parse(text) as unknown) : null

  if (!response.ok) {
    const err = payload as ApiErrorBody | null
    const code = err?.error?.code ?? 'request_failed'
    const message = err?.error?.message ?? response.statusText
    const retryAfter = Number(response.headers.get('Retry-After'))
    throw new ApiError(
      code,
      message,
      err?.error?.attemptsLeft,
      Number.isFinite(retryAfter) && retryAfter > 0 ? retryAfter : undefined,
    )
  }

  return payload as T
}
