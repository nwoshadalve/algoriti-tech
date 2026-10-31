/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { formatBytes } from '@/features/monitoring/format'

export function formatBackupSize(bytes: number): string {
  return formatBytes(bytes)
}
