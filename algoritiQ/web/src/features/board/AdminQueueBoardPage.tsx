/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useEffect, useState } from 'react'
import { listChambers } from '@/core/api/chambers'
import { getBoardSnapshot, startBoardSession } from '@/core/api/board'
import type { BoardSnapshot, BoardTokenView, Chamber } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { SelectField } from '@/core/ui/SelectField'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'
import { CancelTokenModal } from '@/features/board/CancelTokenModal'
import { CurrentCallPanel } from '@/features/board/CurrentCallPanel'
import { PatientEntrySection } from '@/features/board/PatientEntrySection'
import { QueueControlsSection } from '@/features/board/QueueControlsSection'
import { ReprintModal } from '@/features/board/ReprintModal'
import { SessionTokensTable } from '@/features/board/SessionTokensTable'

type TokenDialog = { kind: 'reprint'; token: BoardTokenView } | { kind: 'cancel'; token: BoardTokenView } | null

/** Admin patient entry and queue operations for one chamber ([patient-entry-and-queue-operations.md]). */
export function AdminQueueBoardPage() {
  const { t } = useLocale()
  const toast = useToast()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const isAdmin = account?.role === 'admin'

  const [chambers, setChambers] = useState<Chamber[]>([])
  const [chamberId, setChamberId] = useState('')
  const [snapshot, setSnapshot] = useState<BoardSnapshot | null>(null)
  const [loading, setLoading] = useState(true)
  const [failed, setFailed] = useState(false)
  const [startingSession, setStartingSession] = useState(false)
  const [tokenDialog, setTokenDialog] = useState<TokenDialog>(null)

  const refresh = useCallback(async (id: string) => {
    const token = readSession()
    if (!token || !id) return
    const board = await getBoardSnapshot(token, id)
    setSnapshot(board)
    setFailed(false)
  }, [])

  const load = useCallback(async () => {
    const token = readSession()
    if (!token) return
    setLoading(true)
    setFailed(false)
    try {
      const chamberList = await listChambers(token).catch(() => [] as Chamber[])
      setChambers(chamberList)
      const id = chamberList[0]?.id ?? ''
      setChamberId((current) => current || id)
      if (id) await refresh(id)
    } catch {
      setFailed(true)
    } finally {
      setLoading(false)
    }
  }, [refresh])

  useEffect(() => {
    if (isAdmin) void load()
  }, [isAdmin, load])

  useEffect(() => {
    if (!chamberId || !isAdmin || loading) return
    void refresh(chamberId).catch(() => setFailed(true))
  }, [chamberId, isAdmin, loading, refresh])

  async function startSession() {
    const token = readSession()
    if (!token || !chamberId || startingSession) return
    setStartingSession(true)
    try {
      await startBoardSession(token, chamberId)
      toast.success(t('boardSessionStarted'))
      await refresh(chamberId)
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setStartingSession(false)
    }
  }

  if (!account) return null

  if (!isAdmin) {
    return (
      <div>
        <PageHeader title={t('navBoard')} description={t('boardIntro')} />
        <NoticeBanner tone="error">{t('boardErrorForbidden')}</NoticeBanner>
      </div>
    )
  }

  if (loading && !snapshot) {
    return (
      <div>
        <PageHeader title={t('navBoard')} description={t('boardAdminIntro')} />
        {failed ? (
          <NoticeBanner tone="error">
            <button type="button" className={secondaryButton} onClick={() => void load()}>
              {t('usersRetry')}
            </button>
          </NoticeBanner>
        ) : (
          <PagePreloader />
        )}
      </div>
    )
  }

  const chamberOptions = chambers.map((row) => ({ value: row.id, label: row.name }))
  const sessionOpen = snapshot?.sessionOpen ?? false

  return (
    <div className="min-w-0 space-y-6 pb-10">
      <PageHeader
        title={t('navBoard')}
        description={snapshot ? t('boardAdminIntroNamed', { name: snapshot.chamberName }) : t('boardAdminIntro')}
        actions={
          chambers.length > 0 ? (
            <SelectField
              id="board-chamber"
              label={t('boardChamberLabel')}
              hideLabel
              value={chamberId}
              onChange={(event) => setChamberId(event.target.value)}
              options={chamberOptions}
              className="min-w-[12rem]"
            />
          ) : null
        }
      />

      {failed ? (
        <NoticeBanner tone="error">
          <button type="button" className={secondaryButton} onClick={() => void refresh(chamberId)}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      ) : null}

      {chambers.length === 0 ? (
        <NoticeBanner>{t('boardNoChambers')}</NoticeBanner>
      ) : null}

      {snapshot && !sessionOpen ? (
        <Card as="section" labelledBy="board-session-start">
          <h2 id="board-session-start" className="font-semibold">
            {t('boardSessionClosedTitle')}
          </h2>
          <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('boardSessionClosedHelp')}</p>
          <LoadingButton
            className="mt-4 sm:w-auto sm:min-w-48"
            isLoading={startingSession}
            loadingLabel={t('boardWorking')}
            onClick={() => void startSession()}
          >
            {t('boardStartSession')}
          </LoadingButton>
        </Card>
      ) : null}

      {snapshot && chamberId ? (
        <>
          <PatientEntrySection
            chamberId={chamberId}
            sessionOpen={sessionOpen}
            queueControls={snapshot.queueControls}
            onIssued={() => void refresh(chamberId)}
          />
          <QueueControlsSection
            chamberId={chamberId}
            controls={snapshot.queueControls}
            calledToken={snapshot.calledToken}
            sessionOpen={sessionOpen}
            onRefresh={() => void refresh(chamberId)}
          />
          <CurrentCallPanel
            chamberId={chamberId}
            called={snapshot.calledToken}
            onRefresh={() => void refresh(chamberId)}
            onCancel={(token) => setTokenDialog({ kind: 'cancel', token })}
          />
          <section aria-labelledby="board-session-table">
            <h2 id="board-session-table" className="mb-3 font-semibold">
              {t('boardSessionTableTitle')}
            </h2>
            <SessionTokensTable
              tokens={snapshot.tokens}
              printerBusyTokenId={snapshot.printerBusyTokenId}
              onReprint={(token) => setTokenDialog({ kind: 'reprint', token })}
            />
          </section>
        </>
      ) : null}

      {tokenDialog?.kind === 'reprint' ? (
        <ReprintModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onDone={() => {
            setTokenDialog(null)
            void refresh(chamberId)
          }}
        />
      ) : null}
      {tokenDialog?.kind === 'cancel' ? (
        <CancelTokenModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onDone={() => {
            setTokenDialog(null)
            void refresh(chamberId)
          }}
        />
      ) : null}
    </div>
  )
}
