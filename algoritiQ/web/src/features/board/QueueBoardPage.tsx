/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useCallback, useContext, useEffect, useState } from 'react'
import { listChambers } from '@/core/api/chambers'
import { getQueueDeskSnapshot, pickChamberIdWithOpenSession, startQueueDeskSession } from '@/core/api/queueDesk'
import type { BoardTokenView, Chamber } from '@/core/api/types'
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
import { EditPatientModal } from '@/features/board/EditPatientModal'
import { ExistingPatientModal } from '@/features/board/ExistingPatientModal'
import { QueueControlsSection } from '@/features/board/QueueControlsSection'
import { QueueDeskTableToolbar } from '@/features/board/QueueDeskTableToolbar'
import { queueDeskQueryKeys } from '@/features/board/queueDeskQueryKeys'
import { RegisterPatientModal } from '@/features/board/RegisterPatientModal'
import { SessionPatientActions } from '@/features/board/SessionPatientActions'
import { SessionTokensTable } from '@/features/board/SessionTokensTable'
import { TokenPrintConfirmModal } from '@/features/board/TokenPrintConfirmModal'
import {
  invalidateQueueDeskBoard,
  useQueueDeskSessionTable,
} from '@/features/board/useQueueDeskSessionTable'
import { WorkScopeContext } from '@/features/work/workScopeContext'

type TokenDialog = { kind: 'print'; token: BoardTokenView } | { kind: 'cancel'; token: BoardTokenView } | null

type PatientDialog = { kind: 'new' } | { kind: 'existing' } | null

type QueueBoardPageProps = {
  role: 'admin' | 'receptionist'
}

/** Queue desk: controls + session table; responsive from phone to desktop. */
export function QueueBoardPage({ role }: QueueBoardPageProps) {
  const { t } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const { state } = useAuth()
  const account = state.status === 'signedIn' ? state.account : null
  const workScopeCtx = useContext(WorkScopeContext)
  if (role === 'receptionist' && !workScopeCtx) {
    throw new Error('useWorkScope must be used within WorkScopeProvider')
  }
  const workScopeState = role === 'receptionist' ? workScopeCtx!.state : null

  const [chambers, setChambers] = useState<Chamber[]>([])
  const [chamberId, setChamberId] = useState('')
  const [chambersLoading, setChambersLoading] = useState(role === 'admin')
  const [chambersFailed, setChambersFailed] = useState(false)
  const [startingSession, setStartingSession] = useState(false)
  const [tokenDialog, setTokenDialog] = useState<TokenDialog>(null)
  const [patientDialog, setPatientDialog] = useState<PatientDialog>(null)
  const [editPatientToken, setEditPatientToken] = useState<BoardTokenView | null>(null)

  const receptionistReady = workScopeState?.status === 'ready'
  const fixedChamberId = receptionistReady
    ? workScopeState.selected.deskChamberId ?? workScopeState.selected.id
    : ''
  const activeChamberId = role === 'admin' ? chamberId : fixedChamberId
  const authToken = readSession()
  const boardEnabled = Boolean(
    authToken && activeChamberId && (role !== 'receptionist' || receptionistReady),
  )

  const snapshotQuery = useQuery({
    queryKey: queueDeskQueryKeys.snapshot(activeChamberId),
    queryFn: () =>
      getQueueDeskSnapshot(authToken!, activeChamberId, { includeTokens: false }),
    enabled: boardEnabled,
  })

  const sessionOpen = snapshotQuery.data?.sessionOpen ?? false
  const table = useQueueDeskSessionTable(activeChamberId, sessionOpen)

  const refreshBoard = useCallback(
    (id: string) => {
      invalidateQueueDeskBoard(queryClient, id)
    },
    [queryClient],
  )

  const deskRefresh = useCallback(async () => {
    if (activeChamberId) refreshBoard(activeChamberId)
  }, [activeChamberId, refreshBoard])

  useEffect(() => {
    if (!account || role !== 'admin') return
    const token = readSession()
    if (!token) return
    setChambersLoading(true)
    setChambersFailed(false)
    void listChambers(token)
      .then(async (chamberList) => {
        setChambers(chamberList)
        const preferred = await pickChamberIdWithOpenSession(token, chamberList)
        setChamberId((current) => current || preferred)
      })
      .catch(() => setChambersFailed(true))
      .finally(() => setChambersLoading(false))
  }, [account, role])

  async function startSession() {
    const token = readSession()
    if (!token || !activeChamberId || startingSession) return
    setStartingSession(true)
    try {
      await startQueueDeskSession(token, activeChamberId)
      toast.success(t('boardSessionStarted'))
      refreshBoard(activeChamberId)
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

  const snapshot = snapshotQuery.data
  const boardLoading = boardEnabled && snapshotQuery.isLoading && !snapshot
  const boardFailed = snapshotQuery.isError || chambersFailed

  if ((role === 'admin' && chambersLoading) || boardLoading) {
    return (
      <div>
        <PageHeader
          title={t('navQueueDesk')}
          description={role === 'admin' ? t('boardAdminIntro') : t('boardIntro')}
        />
        {boardFailed ? (
          <NoticeBanner tone="error">
            <button
              type="button"
              className={secondaryButton}
              onClick={() => refreshBoard(activeChamberId)}
            >
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
  const intro =
    snapshot && role === 'admin'
      ? t('boardAdminIntroNamed', { name: snapshot.chamberName })
      : snapshot && role === 'receptionist'
        ? t('workScopeActive', { name: snapshot.chamberName })
        : t('boardAdminIntro')

  return (
    <div className="flex min-h-0 min-w-0 flex-1 flex-col gap-4 pb-6 lg:max-h-[calc(100dvh-8rem)]">
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
              className="min-w-0 w-full sm:min-w-[12rem] sm:w-auto"
            />
          ) : null
        }
      />

      {boardFailed ? (
        <NoticeBanner tone="error">
          <button type="button" className={secondaryButton} onClick={() => refreshBoard(activeChamberId)}>
            {t('usersRetry')}
          </button>
        </NoticeBanner>
      ) : null}

      {sessionOpen && table.isError ? (
        <NoticeBanner tone="error">
          {t(boardErrorKey(table.error))}
          <button
            type="button"
            className={`${secondaryButton} mt-2`}
            onClick={() => table.refreshTable()}
          >
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
            className="mt-4 w-full sm:w-auto sm:min-w-48"
            isLoading={startingSession}
            loadingLabel={t('boardWorking')}
            onClick={() => void startSession()}
          >
            {t('boardStartSession')}
          </LoadingButton>
        </Card>
      ) : null}

      {snapshot && activeChamberId && sessionOpen ? (
        <div className="flex min-h-0 min-w-0 flex-1 flex-col gap-4 xl:flex-row xl:items-stretch">
          <aside className="flex w-full shrink-0 flex-col gap-3 xl:w-[min(100%,20rem)] xl:max-w-xs">
            <CurrentCallPanel
              layout="desk"
              chamberId={activeChamberId}
              called={snapshot.calledToken}
              onRefresh={() => refreshBoard(activeChamberId)}
              onCancel={(token) => setTokenDialog({ kind: 'cancel', token })}
            />
            <QueueControlsSection
              layout="desk"
              chamberId={activeChamberId}
              controls={snapshot.queueControls}
              calledToken={snapshot.calledToken}
              sessionOpen={sessionOpen}
              onRefresh={() => refreshBoard(activeChamberId)}
            />
          </aside>

          <section
            aria-labelledby="board-session-table"
            className="flex min-h-0 min-w-0 flex-1 flex-col overflow-hidden rounded-2xl border border-brand-navy/10 bg-white shadow-sm dark:border-white/10 dark:bg-brand-navy-raised xl:min-h-[20rem]"
          >
            <header className="flex flex-wrap items-center justify-between gap-3 border-b border-brand-navy/10 px-3 py-3 dark:border-white/10 sm:px-4">
              <h2
                id="board-session-table"
                className="text-xs font-bold tracking-wide text-brand-navy/70 uppercase dark:text-white/70"
              >
                {t('boardSessionTableTitle')}
              </h2>
              <SessionPatientActions
                sessionOpen={sessionOpen}
                onAddNew={() => setPatientDialog({ kind: 'new' })}
                onAddExisting={() => setPatientDialog({ kind: 'existing' })}
              />
            </header>
            <QueueDeskTableToolbar
              search={table.searchInput}
              onSearchChange={table.setSearchInput}
              status={table.status}
              onStatusChange={table.setStatus}
              queueTypeId={table.queueTypeId}
              onQueueChange={table.setQueueTypeId}
              notPrintedOnly={table.notPrintedOnly}
              onToggleNotPrinted={table.setNotPrintedOnly}
              sort={table.sort}
              ascending={table.ascending}
              onSort={table.toggleSort}
              counts={table.counts}
              total={table.total}
              queues={snapshot.queueControls}
              hasFilters={table.hasFilters}
              onClear={table.clearFilters}
            />
            <SessionTokensTable
              tokens={table.tokens}
              printerBusyTokenId={snapshot.printerBusyTokenId}
              sort={table.sort}
              ascending={table.ascending}
              onSort={table.toggleSort}
              emptyFiltered={table.hasFilters && table.tokens.length === 0 && !table.isLoading}
              onClearFilters={table.clearFilters}
              hasMore={table.hasMore}
              isLoadingMore={table.isLoadingMore}
              onLoadMore={table.loadMore}
              onPrint={(token) => setTokenDialog({ kind: 'print', token })}
              onReprint={(token) => setTokenDialog({ kind: 'print', token })}
              onEditPatient={(token) => setEditPatientToken(token)}
              onCancel={(token) => setTokenDialog({ kind: 'cancel', token })}
              embedded
            />
          </section>
        </div>
      ) : null}

      {patientDialog?.kind === 'new' && snapshot ? (
        <RegisterPatientModal
          chamberId={activeChamberId}
          queueControls={snapshot.queueControls}
          onClose={() => setPatientDialog(null)}
          onDone={() => deskRefresh()}
        />
      ) : null}
      {patientDialog?.kind === 'existing' && snapshot ? (
        <ExistingPatientModal
          chamberId={activeChamberId}
          queueControls={snapshot.queueControls}
          onClose={() => setPatientDialog(null)}
          onDone={() => deskRefresh()}
        />
      ) : null}

      {tokenDialog?.kind === 'print' ? (
        <TokenPrintConfirmModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onRefresh={() => deskRefresh()}
          onDone={() => setTokenDialog(null)}
        />
      ) : null}
      {tokenDialog?.kind === 'cancel' ? (
        <CancelTokenModal
          token={tokenDialog.token}
          onClose={() => setTokenDialog(null)}
          onDone={() => {
            setTokenDialog(null)
            void deskRefresh()
          }}
        />
      ) : null}
      {editPatientToken ? (
        <EditPatientModal
          token={editPatientToken}
          onClose={() => setEditPatientToken(null)}
          onSaved={() => {
            setEditPatientToken(null)
            refreshBoard(activeChamberId)
          }}
        />
      ) : null}
    </div>
  )
}
