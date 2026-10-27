import type { MessageKey } from '@/core/i18n/messages/types'

const USERNAME_PATTERN = /^[a-zA-Z0-9._-]{3,32}$/

export type RegistrationFields = {
  username: string
  displayName: string
  password: string
  confirmPassword: string
}

export type FieldErrorKey = Extract<
  MessageKey,
  | 'errorUsernameRequired'
  | 'errorUsernameInvalid'
  | 'errorDisplayNameTooLong'
  | 'errorPasswordRequired'
  | 'errorPasswordTooShort'
  | 'errorPasswordTooLong'
  | 'errorPasswordContainsUsername'
  | 'errorConfirmPasswordRequired'
  | 'errorConfirmPasswordMismatch'
>

export type FieldErrors = Partial<Record<keyof RegistrationFields, FieldErrorKey>>

export function normalizeClaimCode(value: string): string {
  return value.replace(/[\s-]/g, '').toUpperCase()
}

export function validateActivationCode(raw: string): MessageKey | null {
  const claim = raw.trim()
  if (!claim) {
    return 'errorActivationCodeRequired'
  }
  if (normalizeClaimCode(claim).length < 4) {
    return 'errorActivationCodeInvalid'
  }
  return null
}

export function validateRegistration(fields: RegistrationFields): FieldErrors {
  const errors: FieldErrors = {}
  const username = fields.username.trim()
  const password = fields.password
  const displayName = fields.displayName.trim()

  if (!username) {
    errors.username = 'errorUsernameRequired'
  } else if (!USERNAME_PATTERN.test(username)) {
    errors.username = 'errorUsernameInvalid'
  }

  if (displayName.length > 80) {
    errors.displayName = 'errorDisplayNameTooLong'
  }

  if (!password) {
    errors.password = 'errorPasswordRequired'
  } else if (password.length < 10) {
    errors.password = 'errorPasswordTooShort'
  } else if (password.length > 128) {
    errors.password = 'errorPasswordTooLong'
  } else if (username && password.toLowerCase().includes(username.toLowerCase())) {
    errors.password = 'errorPasswordContainsUsername'
  }

  if (!fields.confirmPassword) {
    errors.confirmPassword = 'errorConfirmPasswordRequired'
  } else if (fields.confirmPassword !== password) {
    errors.confirmPassword = 'errorConfirmPasswordMismatch'
  }

  return errors
}

export function hasFieldErrors(errors: FieldErrors): boolean {
  return Object.keys(errors).length > 0
}
