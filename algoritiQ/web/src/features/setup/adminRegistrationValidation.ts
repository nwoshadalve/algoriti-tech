import type { MessageKey } from '@/core/i18n/messages/types'

const USERNAME_PATTERN = /^[a-zA-Z0-9._-]{3,32}$/
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
export const MIN_PASSWORD_LENGTH = 8

export type RegistrationFields = {
  firstName: string
  lastName: string
  email: string
  username: string
  password: string
  confirmPassword: string
}

export type FieldErrorKey = Extract<
  MessageKey,
  | 'errorFirstNameRequired'
  | 'errorFirstNameTooLong'
  | 'errorLastNameRequired'
  | 'errorLastNameTooLong'
  | 'errorEmailRequired'
  | 'errorEmailInvalid'
  | 'errorUsernameRequired'
  | 'errorUsernameInvalid'
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
  const firstName = fields.firstName.trim()
  const lastName = fields.lastName.trim()
  const email = fields.email.trim()
  const username = fields.username.trim()
  const password = fields.password

  if (!firstName) {
    errors.firstName = 'errorFirstNameRequired'
  } else if (firstName.length > 64) {
    errors.firstName = 'errorFirstNameTooLong'
  }

  if (!lastName) {
    errors.lastName = 'errorLastNameRequired'
  } else if (lastName.length > 64) {
    errors.lastName = 'errorLastNameTooLong'
  }

  if (!email) {
    errors.email = 'errorEmailRequired'
  } else if (email.length > 254 || !EMAIL_PATTERN.test(email)) {
    errors.email = 'errorEmailInvalid'
  }

  if (!username) {
    errors.username = 'errorUsernameRequired'
  } else if (!USERNAME_PATTERN.test(username)) {
    errors.username = 'errorUsernameInvalid'
  }

  if (!password) {
    errors.password = 'errorPasswordRequired'
  } else if (password.length < MIN_PASSWORD_LENGTH) {
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
