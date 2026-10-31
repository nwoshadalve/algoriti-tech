/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import { getUsersContext, updateUser } from '@/core/api/users'
import type { ManagedUser, UserSort, UsersQuery } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { PlusIcon } from '@/core/ui/icons'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { canObserveScroll } from '@/core/ui/canObserveScroll'
import { ScrollSentinel } from '@/core/ui/ScrollSentinel'
import { useDebouncedValue } from '@/core/ui/useDebouncedValue'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { DisableUserModal } from '@/features/users/DisableUserModal'
import { SetUserPasswordModal } from '@/features/users/SetUserPasswordModal'
import { UserFormModal } from '@/features/users/UserFormModal'
import { UsersTable } from '@/features/users/UsersTable'
import { UsersToolbar } from '@/features/users/UsersToolbar'
import { usersErrorKey } from '@/features/users/usersErrorMessages'
import { usersQueryKeys } from '@/features/users/usersQueryKeys'
import { canDisableUser, canSetUserPassword } from '@/features/users/usersPermissions'
import { useUsersList } from '@/features/users/useUsersList'

const SEARCH_PAUSE_MS = 300

type Dialog =
  | { kind: 'create' }
  | { kind: 'edit'; user: ManagedUser }
  | { kind: 'password'; user: ManagedUser }
  | { kind: 'disable'; user: ManagedUser }
  | null

/** Everyone who can sign in: a table the tablet searches, filters, sorts and pages. */
export function UsersPage() {
  const { t } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const { state } = useAuth()
  const [searchText, setSearchText] = useState('')
  const [filters, setFilters] = useState<Omit<UsersQuery, 'search'>>({
    role: '',
    status: '',
    sort: 'name',
    dir: 'asc',
  })
  const [dialog, setDialog] = useState<Dialog>(null)
  const search = useDebouncedValue(searchText, SEARCH_PAUSE_MS)
  const query: UsersQuery = { ...filters, search }

  const account = state.status === 'signedIn' ? state.account : null
  const isAdmin = account?.role === 'admin'
  const list = useUsersList(query, isAdmin)

  const contextQuery = useQuery({
    queryKey: usersQueryKeys.context(),
    queryFn: async () => {
      const token = readSession()
      if (!token) throw new Error('signed_out')
      return getUsersContext(token)
    },
    enabled: isAdmin,
    retry: false,
  })

  const context = contextQuery.data ?? null

  if (!account) return null

  if (!isAdmin) {
    return (
      <div>
        <PageHeader title={t('navUsers')} description={t('usersIntro')} />
        <NoticeBanner tone="error">{t('usersErrorForbidden')}</NoticeBanner>
      </div>
    )
  }

  const filtered = Boolean(search.trim() || filters.role || filters.status)
  const onboardingKey: MessageKey =
    context?.assignmentTarget === 'doctor' ? 'usersOnboardingDoctors' : 'usersOnboardingChambers'

  function sortBy(sort: UserSort) {
    setFilters((current) => ({
      ...current,
      sort,
      dir: current.sort === sort && current.dir === 'asc' ? 'desc' : 'asc',
    }))
  }

  function clearFilters() {
    setSearchText('')
    setFilters((current) => ({ ...current, role: '', status: '' }))
  }

  async function enable(user: ManagedUser) {
    const token = readSession()
    if (!token) return
    try {
      const saved = await updateUser(token, user.id, {
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        phone: user.phone,
        status: 'active',
      })
      list.replace(saved)
      toast.success(t('usersEnabled'))
    } catch (error) {
      toast.error(t(usersErrorKey(error)))
    }
  }

  return (
    <div>
      <PageHeader
        title={t('navUsers')}
        description={t('usersIntro')}
        actions={
          <LoadingButton
            onClick={() => setDialog({ kind: 'create' })}
            disabled={!context}
            className="inline-flex items-center justify-center gap-2 sm:w-auto"
          >
            <span className="inline-flex items-center gap-2">
              <PlusIcon />
              {t('usersAddUser')}
            </span>
          </LoadingButton>
        }
      />

      {context?.onboarding.needsAttention ? (
        <div className="mb-6 rounded-2xl border border-brand-coral/35 bg-brand-coral/5 px-4 py-3 text-sm dark:border-brand-coral/30 dark:bg-brand-coral/10 sm:px-5">
          <p className="font-semibold">{t('usersOnboardingTitle')}</p>
          <p className="mt-1 text-brand-navy/80 dark:text-white/80">{t(onboardingKey)}</p>
        </div>
      ) : null}

      <UsersToolbar
        search={searchText}
        onSearch={setSearchText}
        query={query}
        onChange={(changes) => setFilters((current) => ({ ...current, ...changes }))}
      />

      <p className="mt-4 mb-3 min-h-5 text-sm text-brand-navy/70 dark:text-white/70" role="status">
        {list.loading ? '' : t('usersShowing', { shown: list.users.length, total: list.total })}
      </p>

      {list.loading ? (
        <PagePreloader label={t('loadingLabel')} />
      ) : list.failed ? (
        <Card className="text-center">
          <p className="text-sm">{t('usersLoadFailed')}</p>
          <button type="button" className={`${secondaryButton} mt-4`} onClick={list.reload}>
            {t('usersRetry')}
          </button>
        </Card>
      ) : list.users.length === 0 ? (
        <Card className="text-center">
          <p className="text-sm">{t('usersNoMatch')}</p>
          {filtered ? (
            <button type="button" className={`${secondaryButton} mt-4`} onClick={clearFilters}>
              {t('usersClearFilters')}
            </button>
          ) : null}
        </Card>
      ) : (
        <>
          <UsersTable
            users={list.users}
            query={query}
            onSort={sortBy}
            onEdit={(user) => setDialog({ kind: 'edit', user })}
            canSetPassword={(user) => (context ? canSetUserPassword(account, user, context) : false)}
            canDisable={(user) => (context ? canDisableUser(account, user, context) : false)}
            onSetPassword={(user) => setDialog({ kind: 'password', user })}
            onToggle={(user) =>
              user.status === 'active' ? setDialog({ kind: 'disable', user }) : void enable(user)
            }
          />
          <ScrollSentinel onReach={list.loadMore} disabled={!list.hasMore || list.loadingMore} />
          <div className="mt-4 flex min-h-11 items-center justify-center">
            {list.loadingMore ? (
              <p className="text-sm text-brand-navy/70 dark:text-white/70">{t('usersLoadingMore')}</p>
            ) : list.moreFailed ? (
              <button type="button" className={secondaryButton} onClick={list.loadMore}>
                {t('usersRetry')}
              </button>
            ) : list.hasMore && !canObserveScroll() ? (
              <button type="button" className={secondaryButton} onClick={list.loadMore}>
                {t('usersLoadMore')}
              </button>
            ) : null}
          </div>
        </>
      )}

      {dialog?.kind === 'create' && context ? (
        <UserFormModal
          context={context}
          onClose={() => setDialog(null)}
          onSaved={() => {
            setDialog(null)
            list.reload()
            void queryClient.invalidateQueries({ queryKey: usersQueryKeys.context() })
          }}
        />
      ) : null}
      {dialog?.kind === 'edit' && context ? (
        <UserFormModal
          user={dialog.user}
          context={context}
          onClose={() => setDialog(null)}
          onSaved={(saved) => {
            setDialog(null)
            list.replace(saved)
          }}
        />
      ) : null}
      {dialog?.kind === 'password' ? (
        <SetUserPasswordModal
          user={dialog.user}
          onClose={() => setDialog(null)}
          onSaved={() => setDialog(null)}
        />
      ) : null}
      {dialog?.kind === 'disable' ? (
        <DisableUserModal
          user={dialog.user}
          onClose={() => setDialog(null)}
          onDisabled={(saved) => {
            setDialog(null)
            list.replace(saved)
          }}
        />
      ) : null}
    </div>
  )
}
