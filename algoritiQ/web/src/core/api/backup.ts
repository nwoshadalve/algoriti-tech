/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { config } from '@/core/config'
import { apiFetch, bearer } from '@/core/api/client'

export type BackupSchedule = 'off' | 'daily' | 'weekly'

export type BackupKind = 'manual' | 'automatic'

export type BackupEntry = {
  id: string
  createdAt: string
  sizeBytes: number
  kind: BackupKind
}

export type BackupSettings = {
  schedule: BackupSchedule
  retentionLimit: number
}

export function getBackupSettings(token: string): Promise<BackupSettings> {
  return apiFetch<BackupSettings>('/backups/settings', { headers: bearer(token) })
}

export function updateBackupSettings(token: string, schedule: BackupSchedule): Promise<BackupSettings> {
  return apiFetch<BackupSettings>('/backups/settings', {
    method: 'PUT',
    headers: bearer(token),
    body: JSON.stringify({ schedule }),
  })
}

export function listBackups(token: string): Promise<{ backups: BackupEntry[] }> {
  return apiFetch<{ backups: BackupEntry[] }>('/backups', { headers: bearer(token) })
}

export function createBackup(token: string): Promise<BackupEntry> {
  return apiFetch<BackupEntry>('/backups', {
    method: 'POST',
    headers: bearer(token),
  })
}

export async function uploadBackup(token: string, file: File): Promise<BackupEntry> {
  const response = await fetch(`${config.apiBasePath}/backups/import`, {
    method: 'POST',
    headers: {
      ...bearer(token),
      'Content-Type': 'application/zip',
    },
    body: file,
  })
  if (!response.ok) {
    const text = await response.text()
    let message = text || response.statusText
    try {
      const payload = JSON.parse(text) as { error?: { message?: string } }
      if (payload.error?.message) message = payload.error.message
    } catch {
      /* use raw text */
    }
    throw new Error(message)
  }
  return (await response.json()) as BackupEntry
}

export function deleteBackup(token: string, id: string): Promise<void> {
  return apiFetch<void>(`/backups/${encodeURIComponent(id)}`, {
    method: 'DELETE',
    headers: bearer(token),
  })
}

export type RestoreBackupResponse = {
  restored: boolean
  restartRequired: boolean
}

export function restoreBackup(token: string, id: string): Promise<RestoreBackupResponse> {
  return apiFetch<RestoreBackupResponse>(`/backups/${encodeURIComponent(id)}/restore`, {
    method: 'POST',
    headers: bearer(token),
  })
}

/** Saves the zip to the browser downloads folder (keep a copy off the tablet). */
export async function downloadBackup(token: string, id: string): Promise<void> {
  const response = await fetch(
    `${config.apiBasePath}/backups/${encodeURIComponent(id)}/download`,
    { headers: bearer(token) },
  )
  if (!response.ok) {
    const text = await response.text()
    throw new Error(text || response.statusText)
  }
  const blob = await response.blob()
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `algoritiq-backup-${id}.zip`
  link.click()
  URL.revokeObjectURL(url)
}
