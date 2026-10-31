/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** After a local queue save, the tablet echoes the same change on the live channel. */
let suppressQueueLiveToastUntil = 0

export function markQueueConfigurationSavedLocally(durationMs = 3_000) {
  suppressQueueLiveToastUntil = Date.now() + durationMs
}

export function shouldShowQueueConfigurationLiveToast() {
  return Date.now() > suppressQueueLiveToastUntil
}
