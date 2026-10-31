/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */

/** Backup settings and stored copies ([/backup]). */
export const backupQueryKeys = {
  all: ['backup'] as const,
  dashboard: () => [...backupQueryKeys.all, 'dashboard'] as const,
}
