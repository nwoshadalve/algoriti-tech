/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState, type FormEvent } from 'react'
import { ApiError } from '@/core/api/client'
import { createUser, updateUser } from '@/core/api/users'
import type { ManagedUser, Role, UsersContext } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { roleLabelKey } from '@/core/i18n/roleLabel'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { PasswordField } from '@/core/ui/PasswordField'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { ScopePicker } from '@/features/users/ScopePicker'
import { usersErrorKey } from '@/features/users/usersErrorMessages'
import {
  hasFieldErrors,
  validateCreate,
  validateEdit,
  type FieldErrors,
  type UserFields,
} from '@/features/users/userValidation'

type UserFormModalProps = {
  /** The person being edited; omit to add a new one. */
  user?: ManagedUser
  context: UsersContext
  onClose: () => void
  /** Saved: the created or changed user. */
  onSaved: (user: ManagedUser, created: boolean) => void
}

const formId = 'user-form'

/** Which field a refusal from the tablet belongs to. */
const fieldOfCode: Record<string, keyof UserFields> = {
  username_taken: 'username',
  username_invalid: 'username',
  email_taken: 'email',
  email_invalid: 'email',
  password_too_short: 'password',
  password_too_long: 'password',
  password_contains_username: 'password',
  first_name_missing: 'firstName',
  name_too_long: 'firstName',
  phone_invalid: 'phone',
}

const roles: { value: Role; help: MessageKey }[] = [
  { value: 'receptionist', help: 'usersRoleReceptionistHelp' },
  { value: 'admin', help: 'usersRoleAdminHelp' },
]

/** One popup for both adding a user and editing one. */
export function UserFormModal({ user, context, onClose, onSaved }: UserFormModalProps) {
  const { t } = useLocale()
  const toast = useToast()
  const editing = user !== undefined
  const [role, setRole] = useState<Role>(user?.role ?? 'receptionist')
  const [fields, setFields] = useState<UserFields>({
    username: user?.username ?? '',
    firstName: user?.firstName ?? '',
    lastName: user?.lastName ?? '',
    email: user?.email ?? '',
    phone: user?.phone ?? '',
    password: '',
    confirmPassword: '',
  })
  const [scopeIds, setScopeIds] = useState<string[]>(user?.scopeIds ?? [])
  const [errors, setErrors] = useState<FieldErrors>({})
  const [busy, setBusy] = useState(false)

  const scopeLabel =
    context.assignmentTarget === 'chamber' ? t('usersScopeChambers') : t('usersScopeDoctors')

  function set(key: keyof UserFields, value: string) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found = editing ? validateEdit(fields) : validateCreate(fields)
    setErrors(found)
    if (hasFieldErrors(found)) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token) return

    setBusy(true)
    try {
      const saved = editing
        ? await updateUser(token, user.id, {
            firstName: fields.firstName.trim(),
            lastName: fields.lastName.trim(),
            email: fields.email.trim(),
            phone: fields.phone.trim(),
            ...(role === 'receptionist' ? { scopeIds } : {}),
          })
        : await createUser(token, {
            role,
            username: fields.username.trim().toLowerCase(),
            firstName: fields.firstName.trim(),
            lastName: fields.lastName.trim(),
            email: fields.email.trim(),
            password: fields.password,
            scopeIds: role === 'receptionist' ? scopeIds : [],
          })
      toast.success(t(editing ? 'usersSaved' : 'usersCreated'))
      onSaved(saved, !editing)
    } catch (error) {
      const key = usersErrorKey(error)
      const field = error instanceof ApiError ? fieldOfCode[error.code] : undefined
      if (field) setErrors({ [field]: key })
      toast.error(t(key))
      setBusy(false)
    }
  }

  const error = (key: keyof UserFields) => {
    const message = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Modal
      title={t(editing ? 'usersEditTitle' : 'usersCreateTitle')}
      description={editing ? t('usersEditIntro', { username: user.username }) : t('usersAddIntro')}
      size="lg"
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            type="submit"
            form={formId}
            isLoading={busy}
            loadingLabel={t('usersSaving')}
            className="sm:w-auto sm:min-w-40"
          >
            {editing ? t('usersSave') : t('usersAddSubmit')}
          </LoadingButton>
        </>
      }
    >
      <form id={formId} className="space-y-5" onSubmit={(event) => void onSubmit(event)} noValidate>
        {editing ? (
          <p className="text-sm text-brand-navy/70 dark:text-white/70">
            {t('usersColRole')}: <span className="font-semibold">{t(roleLabelKey[user.role])}</span>
          </p>
        ) : (
          <fieldset>
            <legend className="mb-2 text-sm font-medium">{t('usersColRole')}</legend>
            <div className="grid gap-2 sm:grid-cols-2">
              {roles.map((option) => (
                <label
                  key={option.value}
                  className={[
                    'flex cursor-pointer items-start gap-3 rounded-xl border px-3 py-3 text-sm transition-colors',
                    role === option.value
                      ? 'border-brand-coral/60 bg-brand-coral/5 dark:border-brand-coral/50 dark:bg-brand-coral/10'
                      : 'border-brand-navy/15 hover:bg-brand-mist dark:border-white/15 dark:hover:bg-white/5',
                  ].join(' ')}
                >
                  <input
                    type="radio"
                    name="user-role"
                    value={option.value}
                    checked={role === option.value}
                    onChange={() => setRole(option.value)}
                    className="mt-0.5 size-4 shrink-0 accent-brand-coral-action"
                  />
                  <span>
                    <span className="block font-semibold">{t(roleLabelKey[option.value])}</span>
                    <span className="mt-0.5 block text-xs text-brand-navy/70 dark:text-white/70">
                      {t(option.help)}
                    </span>
                  </span>
                </label>
              ))}
            </div>
          </fieldset>
        )}

        <div className="grid gap-4 sm:grid-cols-2">
          <TextField
            id="user-first-name"
            label={t('fieldFirstName')}
            autoComplete="off"
            value={fields.firstName}
            error={error('firstName')}
            onChange={(event) => set('firstName', event.target.value)}
          />
          <TextField
            id="user-last-name"
            label={t('fieldLastName')}
            autoComplete="off"
            value={fields.lastName}
            error={error('lastName')}
            onChange={(event) => set('lastName', event.target.value)}
          />
        </div>
        <TextField
          id="user-email"
          label={t('fieldEmail')}
          type="email"
          autoComplete="off"
          spellCheck={false}
          value={fields.email}
          error={error('email')}
          onChange={(event) => set('email', event.target.value)}
        />
        {editing ? (
          <TextField
            id="user-phone"
            label={t('fieldPhone')}
            type="tel"
            autoComplete="off"
            value={fields.phone}
            error={error('phone')}
            onChange={(event) => set('phone', event.target.value)}
          />
        ) : (
          <>
            <TextField
              id="user-username"
              label={t('fieldUsername')}
              hint={t('fieldUsernameHint')}
              autoComplete="off"
              autoCapitalize="none"
              spellCheck={false}
              value={fields.username}
              error={error('username')}
              onChange={(event) => set('username', event.target.value)}
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <PasswordField
                id="user-password"
                label={t('fieldPassword')}
                hint={t('fieldPasswordHint')}
                autoComplete="new-password"
                value={fields.password}
                error={error('password')}
                onChange={(event) => set('password', event.target.value)}
              />
              <PasswordField
                id="user-confirm-password"
                label={t('fieldConfirmPassword')}
                autoComplete="new-password"
                value={fields.confirmPassword}
                error={error('confirmPassword')}
                onChange={(event) => set('confirmPassword', event.target.value)}
              />
            </div>
          </>
        )}

        {role === 'receptionist' ? (
          <ScopePicker
            label={scopeLabel}
            targets={context.targets}
            selected={scopeIds}
            onChange={setScopeIds}
            disabled={busy}
          />
        ) : null}
      </form>
    </Modal>
  )
}
