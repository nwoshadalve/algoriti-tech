/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
/** Human-readable wait for lockout toasts (20 s, 2 minutes, 3 hours, …). */
export function formatRetryWait(totalSeconds: number): string {
  const seconds = Math.max(1, Math.ceil(totalSeconds))
  if (seconds < 60) {
    return seconds === 1 ? '1 second' : `${seconds} seconds`
  }
  const minutes = Math.ceil(seconds / 60)
  if (minutes < 60) {
    return minutes === 1 ? '1 minute' : `${minutes} minutes`
  }
  const hours = Math.ceil(minutes / 60)
  return hours === 1 ? '1 hour' : `${hours} hours`
}

export function formatRetryWaitBn(totalSeconds: number): string {
  const seconds = Math.max(1, Math.ceil(totalSeconds))
  if (seconds < 60) {
    return `${seconds} সেকেন্ড`
  }
  const minutes = Math.ceil(seconds / 60)
  if (minutes < 60) {
    return `${minutes} মিনিট`
  }
  const hours = Math.ceil(minutes / 60)
  return `${hours} ঘণ্টা`
}
