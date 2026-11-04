/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useCallback, useContext, useEffect, useState } from 'react'
import { listChambers } from '@/core/api/chambers'
import { getQueueDeskSnapshot, startQueueDeskSession } from '@/core/api/queueDesk'
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
import { ExistingPatientModal } from '@/features/board/ExistingPatientModal'
import { QueueControlsSection } from '@/features/board/QueueControlsSection'
import { RegisterPatientModal } from '@/features/board/RegisterPatientModal'
import { ReprintModal } from '@/features/board/ReprintModal'
import { SessionPatientActions } from '@/features/board/SessionPatientActions'
import { SessionTokensTable } from '@/features/board/SessionTokensTable'
import { WorkScopeContext } from '@/features/work/workScopeContext'

type TokenDialog = { kind: 'reprint'; token: BoardTokenView } | { kind: 'cancel'; token: BoardTokenView } | null

type PatientDialog = { kind: 'new' } | { kind: 'existing' } | null

type QueueBoardPageProps = {
  role: 'admin' | 'receptionist'
}

/** Queue desk: left queue control (⅓), right session table (⅔); patient entry in modals. */
export function QueueBoardPage({ role }: QueueBoardPageProps) {
  const { t } = useLocale()
  const toast = useToast()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const workScopeCtx = useContext(WorkScopeContext)
  if (role === 'receptionist' && !workScopeCtx) {
    throw new Error('useWorkScope must be used within WorkScopeProvider')
  }
  const workScopeState = role === 'receptionist' ? workScopeCtx!.state : null

  const [chambers, setChambers] = useState<Chamber[]>([])
  const [chamberId, setChamberId] = useState('')
  const [snapshot, setSnapshot] = useState<BoardSnapshot | null>(null)
  const [loading, setLoading] = useState(true)
  const [failed, setFailed] = useState(false)
  const [startingSession, setStartingSession] = useState(false)
  const [tokenDialog, setTokenDialog] = useState<TokenDialog>(null)
  const [patientDialog, setPatientDialog] = useState<PatientDialog>(null)

  const receptionistReady = workScopeState?.status === 'ready'
  const fixedChamberId = receptionistReady ? workScopeState.selected.id : ''
  const activeChamberId = role === 'admin' ? chamberId : fixedChamberId

  const refresh = useCallback(async (id: string) => {
    const token = readSession()
    if (!token || !id) return
    const board = await getQueueDeskSnapshot(token, id)
    setSnapshot(board)
    setFailed(false)
  }, [])

  const load = useCallback(async () => {
    const token = readSession()
    if (!token) return
    if (role === 'receptionist') {
      if (workScopeState?.status !== 'ready') {
        setLoading(false)
        return
      }
      setLoading(true)
      setFailed(false)
      try {
        await refresh(workScopeState.selected.id)
      } catch {
        setFailed(true)
      } finally {
        setLoading(false)
      }
      return
    }
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
  }, [refresh, role, workScopeState])

  useEffect(() => {
    if (account) void load()
  }, [account, load])

  useEffect(() => {
    if (!activeChamberId || loading) return
    if (role === 'receptionist' && !receptionistReady) return
    void refresh(activeChamberId).catch(() => setFailed(true))
  }, [activeChamberId, loading, receptionistReady, refresh, role])

  async function startSession() {
    const token = readSession()
    if (!token || !activeChamberId || startingSession) return
    setStartingSession(true)
    try {
      await startQueueDeskSession(token, activeChamberId)
      toast.success(t('boardSessionStarted'))
      await refresh(activeChamberId)
    } catch (error) {
      toast.error(t(boardErrorKey(error)))
    } finally {
      setStartingSession(false)
    }
  }

  if (!account) return null

  if (role === 'receptionist' && workScopeState?.status !== 'ready') {
    return (
      <div>
        <PageHeader title={t('navQueueDesk')} description={t('boardIntro')} />
        <NoticeBanner>
          {workScopeState?.status === 'unassigned' ? t('workScopeEmpty') : t('workScopeIntroChamber')}
        </NoticeBanner>
      </div>
    )
  }

  if (loading && !snapshot) {
    return (
      <div>
        <PageHeader
          title={t('navQueueDesk')}
          description={role === 'admin' ? t('boardAdminIntro') : t('boardIntro')}
        />
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
  const intro =
    snapshot && role === 'admin'
      ? t('boardAdminIntroNamed', { name: snapshot.chamberName })
      : snapshot && role === 'receptionist'
        ? t('workScopeActive', { name: snapshot.chamberName })
        : t('boardAdminIntro')

  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col gap-4 pb-6">
      <PageHeader
        title={t('navQueueDesk')}
        description={intro}
        actions={
          role === 'admin' && chambers.length > 0 ? (
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
          <button type="button" className={secondaryButton} onClick={() => void refresh(activeChamberId)}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      ) : null}

      {role === 'admin' && chambers.length === 0 ? <NoticeBanner>{t('boardNoChambers')}</NoticeBanner> : null}

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

      {snapshot && activeChamberId ? (
        <div className="grid min-h-0 min-w-0 flex-1 gap-4 lg:grid-cols-[minmax(0,1fr)_minmax(0,2fr)]">
          <div className="flex min-w-0 flex-col gap-4">
            <CurrentCallPanel
              layout="desk"
              chamberId={activeChamberId}
              called={snapshot.calledToken}
              onRefresh={() => void refresh(activeChamberId)}
              onCancel={(token) => setTokenDialog({ kind: 'cancel', token })}
            />
            <QueueControlsSection
              layout="desk"
              chamberId={activeChamberId}
              controls={snapshot.queueControls}
              calledToken={snapshot.calledToken}
              sessionOpen={sessionOpen}
              onRefresh={() => void refresh(activeChamberId)}
            />
          </div>

          <section
            aria-labelledby="board-session-table"
            className="flex min-h-0 min-w-0 flex-col overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised"
          >
            <header className="flex flex-wrap items-center justify-between gap-3 border-b border-brand-navy/10 px-4 py-3 dark:border-white/10">
              <h2 id="board-session-table" className="text-xs font-bold tracking-wide text-brand-navy/70 uppercase dark:text-white/70">
                {t('boardSessionTableTitle')}
              </h2>
              <SessionPatientActions
                sessionOpen={sessionOpen}
                onAddNew={() => setPatientDialog({ kind: 'new' })}
                onAddExisting={() => setPatientDialog({ kind: 'existing' })}
              />
            </header>
            <div className="min-h-0 flex-1 overflow-hidden p-2 pt-0">
              <SessionTokensTable
                tokens={snapshot.tokens}
                printerBusyTokenId={snapshot.printerBusyTokenId}
                onReprint={(token) => setTokenDialog({ kind: 'reprint', token })}
                embedded
              />
            </div>
          </section>
        </div>
      ) : null}

      {patientDialog?.kind === 'new' && snapshot ? (
        <RegisterPatientModal
          chamberId={activeChamberId}
          queueControls={snapshot.queueControls}
          onClose={() => setPatientDialog(null)}
          onRegistered={() => {
            setPatientDialog(null)
            void refresh(activeChamberId)
          }}
        />
      ) : null}
      {patientDialog?.kind === 'existing' && snapshot ? (
        <ExistingPatientModal
          chamberId={activeChamberId}
          queueControls={snapshot.queueControls}
          onClose={() => setPatientDialog(null)}
          onIssued={() => {
            setPatientDialog(null)
            void refresh(activeChamberId)
          }}
        />
      ) : null}

      {tokenDialog?.kind === 'reprint' ? (
        <ReprintModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onDone={() => {
            setTokenDialog(null)
            void refresh(activeChamberId)
          }}
        />
      ) : null}
      {tokenDialog?.kind === 'cancel' ? (
        <CancelTokenModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onDone={() => {
            setTokenDialog(null)
            void refresh(activeChamberId)
          }}
        />
      ) : null}
    </div>
  )
}
