/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { QueueTypeConfig } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

export type QueueTypeFields = {
  englishName: string
  bengaliName: string
  startNumber: string
  endNumber: string
}

export type QueueTypeFieldErrors = Partial<Record<keyof QueueTypeFields, MessageKey>>

export function validateQueueTypeFields(
  fields: QueueTypeFields,
  siblings: QueueTypeConfig[],
  editingId: string | undefined,
): QueueTypeFieldErrors {
  const errors: QueueTypeFieldErrors = {}
  if (!fields.englishName.trim()) errors.englishName = 'queueErrorEnglishName'
  if (!fields.bengaliName.trim()) errors.bengaliName = 'queueErrorBengaliName'

  const start = Number(fields.startNumber)
  const end = Number(fields.endNumber)
  if (!Number.isFinite(start) || start <= 0) errors.startNumber = 'queueErrorStart'
  if (!Number.isFinite(end) || end <= 0) errors.endNumber = 'queueErrorEnd'
  if (Number.isFinite(start) && Number.isFinite(end) && start > end) {
    errors.endNumber = 'queueErrorRange'
  }

  const en = fields.englishName.trim().toLowerCase()
  const bn = fields.bengaliName.trim()
  for (const other of siblings) {
    if (other.id === editingId) continue
    if (other.englishName.trim().toLowerCase() === en || other.bengaliName.trim() === bn) {
      errors.englishName = 'queueErrorDuplicateName'
      break
    }
  }

  if (Number.isFinite(start) && Number.isFinite(end) && start <= end && start > 0) {
    for (const other of siblings) {
      if (other.id === editingId || !other.enabled) continue
      const overlap = start <= other.endNumber && end >= other.startNumber
      if (overlap) {
        errors.startNumber = 'queueErrorOverlap'
        break
      }
    }
  }

  return errors
}

export function hasQueueTypeFieldErrors(errors: QueueTypeFieldErrors): boolean {
  return Object.keys(errors).length > 0
}
