/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

type Translate = (key: MessageKey, params?: Record<string, string | number>) => string

const oneDecimal = new Intl.NumberFormat(undefined, { maximumFractionDigits: 1 })

/** `3.2 GB`, `512 MB`: sizes of memory and storage. */
export function formatBytes(bytes: number): string {
  const gb = bytes / 1024 ** 3
  if (gb >= 1) return `${oneDecimal.format(gb)} GB`
  return `${oneDecimal.format(bytes / 1024 ** 2)} MB`
}

/** The two largest units: `2d 4h`, `5h 12m`, `45s`. */
export function formatUptime(t: Translate, totalSeconds: number): string {
  const seconds = Math.max(0, Math.floor(totalSeconds))
  const days = Math.floor(seconds / 86_400)
  const hours = Math.floor((seconds % 86_400) / 3_600)
  const minutes = Math.floor((seconds % 3_600) / 60)
  const parts: string[] = []
  if (days) parts.push(t('monitorDays', { count: days }))
  if (hours) parts.push(t('monitorHours', { count: hours }))
  if (minutes && days === 0) parts.push(t('monitorMinutes', { count: minutes }))
  if (parts.length === 0) parts.push(t('monitorSeconds', { count: seconds % 60 }))
  return parts.slice(0, 2).join(' ')
}
