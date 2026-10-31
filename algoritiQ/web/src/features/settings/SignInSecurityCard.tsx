/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useState, type FormEvent } from 'react'
import { ApiError } from '@/core/api/client'
import { changePassword } from '@/core/api/profile'
import { listPinDevices, removePinDevice, setPin } from '@/core/api/pin'
import type { Account, PinDevice } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'
import { secondaryButton } from '@/core/ui/buttonStyles'
import { Card } from '@/core/ui/Card'
import { TrashIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { Modal } from '@/core/ui/Modal'
import { PasswordField } from '@/core/ui/PasswordField'
import { PinInput } from '@/core/ui/PinInput'
import { authError } from '@/features/auth/authErrors'
import {
  clearPinBrowser,
  describeBrowser,
  readPinBrowser,
  savePinBrowser,
  type PinBrowser,
} from '@/features/auth/pinDevice'
import { saveSignInMode } from '@/features/auth/signInPreference'
import { readSession } from '@/features/auth/session'
import { validatePasswordChange, type PasswordErrors } from '@/features/settings/passwordValidation'
import { validatePin } from '@/features/settings/pinValidation'

const passwordEmpty = { current: '', next: '', confirm: '' }
const changePasswordFormId = 'change-password-form'
const setPinFormId = 'set-pin-form'

type SignInSecurityCardProps = {
  account: Account
  /** Changes when the password was changed and PINs were cleared on the tablet. */
  refreshKey: number
  onPasswordChanged?: () => void
}

/** Password change and quick sign-in PIN in one settings card. */
export function SignInSecurityCard({
  account,
  refreshKey,
  onPasswordChanged,
}: SignInSecurityCardProps) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [devices, setDevices] = useState<PinDevice[] | null>(null)
  const [local, setLocal] = useState<PinBrowser | null>(readPinBrowser)
  const [passwordOpen, setPasswordOpen] = useState(false)
  const [pinOpen, setPinOpen] = useState(false)
  const [pinVersion, setPinVersion] = useState(0)

  useEffect(() => {
    const token = readSession()
    if (!token) return
    let cancelled = false
    listPinDevices(token).then(
      (list) => {
        if (cancelled) return
        setDevices(list)
        const stored = readPinBrowser()
        if (stored && !list.some((device) => device.id === stored.deviceId)) {
          clearPinBrowser()
          setLocal(null)
        } else {
          setLocal(stored)
        }
      },
      () => {
        if (!cancelled) toast.error(t('pinLoadFailed'))
      },
    )
    return () => {
      cancelled = true
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refreshKey, pinVersion])

  const date = new Intl.DateTimeFormat(locale === 'bn' ? 'bn-BD' : 'en-GB', {
    dateStyle: 'medium',
  })

  async function remove(device: PinDevice) {
    const token = readSession()
    if (!token) return
    try {
      await removePinDevice(token, device.id)
      if (local?.deviceId === device.id) {
        clearPinBrowser()
        setLocal(null)
      }
      toast.success(t('pinRemoved'))
      setPinVersion((value) => value + 1)
    } catch (error) {
      const failure = authError(error, locale)
      toast.error(t(failure.key, failure.params))
    }
  }

  const hereHasPin = local !== null && devices?.some((device) => device.id === local.deviceId)

  return (
    <Card as="section" labelledBy="settings-security">
      <h2 id="settings-security" className="text-lg font-semibold">
        {t('securityCardTitle')}
      </h2>
      <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('securityCardIntro')}</p>

      <div className="mt-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="min-w-0">
          <h3 className="text-base font-semibold">{t('passwordCardTitle')}</h3>
          <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('passwordCardIntro')}</p>
        </div>
        <button
          type="button"
          className={`${secondaryButton} shrink-0`}
          aria-haspopup="dialog"
          onClick={() => setPasswordOpen(true)}
        >
          {t('passwordChangeButton')}
        </button>
      </div>

      <hr className="my-6 border-brand-navy/10 dark:border-white/10" />

      <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
        <div className="min-w-0">
          <h3 className="text-base font-semibold">{t('pinCardTitle')}</h3>
          <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('pinCardIntro')}</p>
        </div>
        <button
          type="button"
          className={`${secondaryButton} shrink-0`}
          aria-haspopup="dialog"
          onClick={() => setPinOpen(true)}
        >
          {hereHasPin ? t('pinChangeButton') : t('pinSetButton')}
        </button>
      </div>

      {devices && devices.length === 0 ? (
        <p className="mt-5 text-sm text-brand-navy/70 dark:text-white/70">{t('pinNone')}</p>
      ) : null}
      {devices && devices.length > 0 ? (
        <ul className="mt-5 divide-y divide-brand-navy/10 dark:divide-white/10">
          {devices.map((device) => (
            <li key={device.id} className="flex items-center justify-between gap-3 py-3">
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold">
                  {device.label || t('pinThisBrowser')}
                  {local?.deviceId === device.id ? (
                    <span className="ml-2 rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-900 dark:bg-emerald-950/50 dark:text-emerald-100">
                      {t('pinThisBrowser')}
                    </span>
                  ) : null}
                </p>
                <p className="mt-0.5 text-xs text-brand-navy/65 dark:text-white/65">
                  {device.lastUsedAt
                    ? t('pinLastUsed', { date: date.format(new Date(device.lastUsedAt)) })
                    : t('pinNeverUsed')}
                </p>
              </div>
              <IconButton
                label={t('pinRemove')}
                ariaLabel={`${t('pinRemove')}: ${device.label || t('pinThisBrowser')}`}
                icon={TrashIcon}
                tone="danger"
                onClick={() => void remove(device)}
              />
            </li>
          ))}
        </ul>
      ) : null}

      {passwordOpen ? (
        <ChangePasswordModal
          account={account}
          onClose={() => setPasswordOpen(false)}
          onChanged={() => {
            onPasswordChanged?.()
            setPasswordOpen(false)
          }}
        />
      ) : null}
      {pinOpen ? (
        <SetPinModal
          account={account}
          replaceDeviceId={hereHasPin ? local?.deviceId : undefined}
          onClose={() => setPinOpen(false)}
          onSaved={(browser) => {
            savePinBrowser(browser)
            saveSignInMode('pin')
            setLocal(browser)
            setPinOpen(false)
            setPinVersion((value) => value + 1)
          }}
        />
      ) : null}
    </Card>
  )
}

function ChangePasswordModal({
  account,
  onClose,
  onChanged,
}: {
  account: Account
  onClose: () => void
  onChanged: () => void
}) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [fields, setFields] = useState(passwordEmpty)
  const [errors, setErrors] = useState<PasswordErrors>({})
  const [busy, setBusy] = useState(false)

  function set(key: keyof typeof passwordEmpty, value: string) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found = validatePasswordChange(fields, account.username)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token) return

    setBusy(true)
    try {
      await changePassword(token, fields.current, fields.next)
      toast.success(t('passwordChanged'))
      onChanged()
    } catch (error) {
      const code = error instanceof ApiError ? error.code : ''
      const field: [keyof PasswordErrors, MessageKey] | null =
        code === 'current_password_wrong'
          ? ['current', 'errorCurrentPasswordWrong']
          : code === 'password_unchanged'
            ? ['next', 'errorPasswordUnchanged']
            : code === 'password_too_short'
              ? ['next', 'errorPasswordTooShort']
              : code === 'password_too_long'
                ? ['next', 'errorPasswordTooLong']
                : code === 'password_contains_username'
                  ? ['next', 'errorPasswordContainsUsername']
                  : null
      if (field) {
        setErrors({ [field[0]]: field[1] })
        toast.error(t(field[1]))
      } else {
        const failure = authError(error, locale)
        toast.error(t(failure.key, failure.params))
      }
      setBusy(false)
    }
  }

  const error = (key: keyof PasswordErrors) => {
    const message: MessageKey | undefined = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Modal
      title={t('passwordModalTitle')}
      description={t('passwordCardIntro')}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            type="submit"
            form={changePasswordFormId}
            isLoading={busy}
            loadingLabel={t('passwordChanging')}
            className="sm:w-auto sm:min-w-44"
          >
            {t('passwordChangeButton')}
          </LoadingButton>
        </>
      }
    >
      <form
        id={changePasswordFormId}
        className="space-y-5"
        onSubmit={(event) => void onSubmit(event)}
        noValidate
      >
        <PasswordField
          id="settings-current-password"
          label={t('fieldCurrentPassword')}
          autoComplete="current-password"
          value={fields.current}
          error={error('current')}
          onChange={(event) => set('current', event.target.value)}
        />
        <PasswordField
          id="settings-new-password"
          label={t('fieldNewPassword')}
          hint={t('fieldPasswordHint')}
          autoComplete="new-password"
          value={fields.next}
          error={error('next')}
          onChange={(event) => set('next', event.target.value)}
        />
        <PasswordField
          id="settings-confirm-password"
          label={t('fieldConfirmPassword')}
          autoComplete="new-password"
          value={fields.confirm}
          error={error('confirm')}
          onChange={(event) => set('confirm', event.target.value)}
        />
      </form>
    </Modal>
  )
}

function SetPinModal({
  account,
  replaceDeviceId,
  onClose,
  onSaved,
}: {
  account: Account
  replaceDeviceId?: string
  onClose: () => void
  onSaved: (browser: PinBrowser) => void
}) {
  const { t, locale } = useLocale()
  const toast = useToast()
  const [password, setPassword] = useState('')
  const [pin, setPinValue] = useState('')
  const [confirm, setConfirm] = useState('')
  const [errors, setErrors] = useState<{
    password?: MessageKey
    pin?: MessageKey
    confirm?: MessageKey
  }>({})
  const [busy, setBusy] = useState(false)

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found: typeof errors = {}
    if (!password) found.password = 'errorCurrentPasswordRequired'
    const pinProblem = validatePin(pin)
    if (pinProblem) found.pin = pinProblem
    if (!pinProblem && confirm !== pin) found.confirm = 'errorPinMismatch'
    setErrors(found)
    if (Object.keys(found).length > 0) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token) return

    setBusy(true)
    try {
      const result = await setPin(token, { password, pin, label: describeBrowser(), replaceDeviceId })
      toast.success(t('pinSaved'))
      onSaved({
        deviceToken: result.deviceToken,
        deviceId: result.device.id,
        username: account.username,
        displayName: account.displayName,
      })
    } catch (error) {
      const code = error instanceof ApiError ? error.code : ''
      const failure = authError(error, locale)
      if (code === 'current_password_wrong') setErrors({ password: failure.key })
      else if (code === 'pin_invalid' || code === 'pin_too_easy') setErrors({ pin: failure.key })
      toast.error(t(failure.key, failure.params))
      setBusy(false)
    }
  }

  const message = (key?: MessageKey) => (key ? t(key) : undefined)

  return (
    <Modal
      title={t('pinModalTitle')}
      description={t('pinModalIntro')}
      busy={busy}
      onClose={onClose}
      footer={
        <>
          <button type="button" className={secondaryButton} disabled={busy} onClick={onClose}>
            {t('actionCancel')}
          </button>
          <LoadingButton
            type="submit"
            form={setPinFormId}
            isLoading={busy}
            loadingLabel={t('usersSaving')}
            className="sm:w-auto sm:min-w-40"
          >
            {t('usersSave')}
          </LoadingButton>
        </>
      }
    >
      <form id={setPinFormId} className="space-y-5" onSubmit={(event) => void onSubmit(event)} noValidate>
        <PasswordField
          id="pin-password"
          label={t('fieldCurrentPassword')}
          autoComplete="current-password"
          value={password}
          error={message(errors.password)}
          onChange={(event) => {
            setPassword(event.target.value)
            setErrors((current) => ({ ...current, password: undefined }))
          }}
        />
        <PinInput
          id="pin-new"
          label={t('fieldNewPin')}
          value={pin}
          error={message(errors.pin)}
          onChange={(value) => {
            setPinValue(value)
            setErrors((current) => ({ ...current, pin: undefined }))
          }}
        />
        <PinInput
          id="pin-confirm"
          label={t('fieldConfirmPin')}
          value={confirm}
          error={message(errors.confirm)}
          onChange={(value) => {
            setConfirm(value)
            setErrors((current) => ({ ...current, confirm: undefined }))
          }}
        />
      </form>
    </Modal>
  )
}
