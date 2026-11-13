/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQueries, useQuery } from '@tanstack/react-query'
import { getAnalytics } from '@/core/api/analytics'
import { listAuditLog } from '@/core/api/audit'
import { getBackupSettings, listBackups } from '@/core/api/backup'
import { listChambers } from '@/core/api/chambers'
import { getMonitoring } from '@/core/api/monitoring'
import { getQueueDeskSnapshot } from '@/core/api/queueDesk'
import { listSessionHistory } from '@/core/api/sessionHistory'
import { readSession } from '@/features/auth/session'

const SECOND = 1000
const MINUTE = 60 * SECOND

function token(): string {
  const value = readSession()
  if (!value) throw new Error('signed_out')
  return value
}

export const overviewQueryKeys = {
  all: ['overview'] as const,
  today: ['overview', 'today'] as const,
  week: ['overview', 'week'] as const,
  chambers: ['overview', 'chambers'] as const,
  board: (chamberId: string) => ['overview', 'board', chamberId] as const,
  sessions: ['overview', 'sessions'] as const,
  monitoring: ['overview', 'monitoring'] as const,
  backupSettings: ['overview', 'backup-settings'] as const,
  backups: ['overview', 'backups'] as const,
  audit: ['overview', 'audit'] as const,
}

/**
 * Everything the admin Overview shows. Each part loads and refreshes on its own,
 * so a slow or failing part never blanks the rest: the page draws what it has.
 */
export function useOverview() {
  const today = useQuery({
    queryKey: overviewQueryKeys.today,
    queryFn: () => getAnalytics(token(), { period: 'day' }),
    refetchInterval: 30 * SECOND,
    retry: false,
  })
  const week = useQuery({
    queryKey: overviewQueryKeys.week,
    queryFn: () => getAnalytics(token(), { period: 'week' }),
    refetchInterval: MINUTE,
    retry: false,
  })
  const chambers = useQuery({
    queryKey: overviewQueryKeys.chambers,
    queryFn: () => listChambers(token()),
    retry: false,
  })
  const boards = useQueries({
    queries: (chambers.data ?? []).map((chamber) => ({
      queryKey: overviewQueryKeys.board(chamber.id),
      queryFn: () => getQueueDeskSnapshot(token(), chamber.id, { includeTokens: false }),
      refetchInterval: 10 * SECOND,
      retry: false,
    })),
  })
  const sessions = useQuery({
    queryKey: overviewQueryKeys.sessions,
    queryFn: () => listSessionHistory(token(), { limit: 10 }),
    refetchInterval: 30 * SECOND,
    retry: false,
  })
  const monitoring = useQuery({
    queryKey: overviewQueryKeys.monitoring,
    queryFn: () => getMonitoring(token()),
    refetchInterval: 15 * SECOND,
    retry: false,
  })
  const backupSettings = useQuery({
    queryKey: overviewQueryKeys.backupSettings,
    queryFn: () => getBackupSettings(token()),
    refetchInterval: 5 * MINUTE,
    retry: false,
  })
  const backups = useQuery({
    queryKey: overviewQueryKeys.backups,
    queryFn: () => listBackups(token()),
    refetchInterval: 5 * MINUTE,
    retry: false,
  })
  const audit = useQuery({
    queryKey: overviewQueryKeys.audit,
    queryFn: () => listAuditLog(token()),
    refetchInterval: 30 * SECOND,
    retry: false,
  })

  return { today, week, chambers, boards, sessions, monitoring, backupSettings, backups, audit }
}
