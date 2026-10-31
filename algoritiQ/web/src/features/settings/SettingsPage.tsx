/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState, type FormEvent } from 'react'
import { ApiError } from '@/core/api/client'
import { removePhoto, updateProfile, uploadPhoto } from '@/core/api/profile'
import type { Account, ProfileInput } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import type { MessageKey } from '@/core/i18n/messages/types'
import { Card } from '@/core/ui/Card'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PageHeader } from '@/core/ui/PageHeader'
import { TextField } from '@/core/ui/TextField'
import { useAuth } from '@/features/auth/authContext'
import { readSession } from '@/features/auth/session'
import { validateProfile, type ProfileErrors } from '@/features/settings/profileValidation'
import { SignInSecurityCard } from '@/features/settings/SignInSecurityCard'
import { clearPinBrowser } from '@/features/auth/pinDevice'
import { PhotoCard } from '@/features/settings/PhotoCard'

/** Profile photo and personal information of the signed-in person. */
export function SettingsPage() {
  const { t } = useLocale()
  const { state, updateAccount } = useAuth()
  const [pinVersion, setPinVersion] = useState(0)
  if (state.status !== 'signedIn') return null
  const account = state.account

  return (
    <div>
      <PageHeader title={t('navSettings')} description={t('settingsIntro')} />
      <div className="grid gap-6 lg:grid-cols-[minmax(0,20rem)_minmax(0,1fr)] lg:items-start">
        <PhotoCard
          title={t('settingsPhotoTitle')}
          person={account}
          onUpload={async (square) => {
            const token = readSession()
            if (!token) throw new Error('signed_out')
            updateAccount(await uploadPhoto(token, square))
          }}
          onRemove={async () => {
            const token = readSession()
            if (!token) throw new Error('signed_out')
            updateAccount(await removePhoto(token))
          }}
        />
        <div className="min-w-0 space-y-6">
          <ProfileCard key={account.id} account={account} onSaved={updateAccount} />
          <SignInSecurityCard
            key={`security-${account.id}`}
            account={account}
            refreshKey={pinVersion}
            onPasswordChanged={() => {
              clearPinBrowser()
              setPinVersion((value) => value + 1)
            }}
          />
        </div>
      </div>
    </div>
  )
}

function profileOf(account: Account): ProfileInput {
  return {
    firstName: account.firstName,
    lastName: account.lastName,
    email: account.email,
    phone: account.phone,
  }
}

function ProfileCard({
  account,
  onSaved,
}: {
  account: Account
  onSaved: (account: Account) => void
}) {
  const { t } = useLocale()
  const saved = profileOf(account)
  const [fields, setFields] = useState<ProfileInput>(saved)
  const [errors, setErrors] = useState<ProfileErrors>({})
  const [busy, setBusy] = useState(false)
  const toast = useToast()

  const dirty = (Object.keys(saved) as (keyof ProfileInput)[]).some(
    (key) => fields[key].trim() !== saved[key],
  )

  function set(key: keyof ProfileInput, value: string) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    const found = validateProfile(fields)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      toast.error(t('errorFixFields'))
      return
    }
    const token = readSession()
    if (!token) return

    setBusy(true)
    try {
      const updated = await updateProfile(token, {
        firstName: fields.firstName.trim(),
        lastName: fields.lastName.trim(),
        email: fields.email.trim(),
        phone: fields.phone.trim(),
      })
      onSaved(updated)
      setFields(profileOf(updated))
      toast.success(t('settingsSaved'))
    } catch (error) {
      const code = error instanceof ApiError ? error.code : ''
      // A refusal from the tablet marks the field and says so in a toast too.
      const field: [keyof ProfileInput, MessageKey] | null =
        code === 'email_taken'
          ? ['email', 'errorEmailTaken']
          : code === 'email_invalid'
            ? ['email', 'errorEmailInvalid']
            : code === 'phone_invalid'
              ? ['phone', 'errorPhoneInvalid']
              : code === 'first_name_missing'
                ? ['firstName', 'errorFirstNameRequired']
                : code === 'name_too_long'
                  ? ['firstName', 'errorFirstNameTooLong']
                  : null
      if (field) {
        setErrors({ [field[0]]: field[1] })
        toast.error(t(field[1]))
      } else {
        toast.error(t(error instanceof TypeError ? 'errorNetwork' : 'errorGeneric'))
      }
    } finally {
      setBusy(false)
    }
  }

  const error = (key: keyof ProfileInput) => {
    const message = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Card as="section" labelledBy="settings-profile">
      <h2 id="settings-profile" className="text-lg font-semibold">
        {t('settingsProfileTitle')}
      </h2>
      <p className="mt-1 text-sm text-brand-navy/70 dark:text-white/70">{t('settingsProfileIntro')}</p>

      <form className="mt-6 space-y-5" onSubmit={(event) => void onSubmit(event)} noValidate>
        <div className="grid gap-5 sm:grid-cols-2">
          <TextField
            id="settings-first-name"
            label={t('fieldFirstName')}
            autoComplete="given-name"
            value={fields.firstName}
            error={error('firstName')}
            onChange={(event) => set('firstName', event.target.value)}
          />
          <TextField
            id="settings-last-name"
            label={t('fieldLastName')}
            autoComplete="family-name"
            value={fields.lastName}
            error={error('lastName')}
            onChange={(event) => set('lastName', event.target.value)}
          />
        </div>
        <TextField
          id="settings-email"
          label={t('fieldEmail')}
          type="email"
          autoComplete="email"
          value={fields.email}
          error={error('email')}
          onChange={(event) => set('email', event.target.value)}
        />
        <TextField
          id="settings-phone"
          label={t('fieldPhone')}
          type="tel"
          autoComplete="tel"
          value={fields.phone}
          error={error('phone')}
          onChange={(event) => set('phone', event.target.value)}
        />
        <TextField
          id="settings-username"
          label={t('fieldUsername')}
          value={account.username}
          hint={t('settingsUsernameNote')}
          readOnly
          className="bg-brand-mist dark:bg-brand-navy"
        />


        <div className="pt-1 sm:flex sm:justify-end">
          <LoadingButton
            type="submit"
            isLoading={busy}
            loadingLabel={t('settingsSaving')}
            disabled={!dirty}
            className="sm:w-auto sm:min-w-44"
          >
            {t('settingsSave')}
          </LoadingButton>
        </div>
      </form>
    </Card>
  )
}
