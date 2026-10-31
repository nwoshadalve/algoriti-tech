/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { MessageKey } from '@/core/i18n/messages/types'

export type UserFields = {
  username: string
  firstName: string
  lastName: string
  email: string
  phone: string
  password: string
  confirmPassword: string
}

export type FieldErrors = Partial<Record<keyof UserFields, MessageKey>>

const usernamePattern = /^[a-z0-9._-]{3,32}$/

export function validateCreate(fields: UserFields): FieldErrors {
  const errors: FieldErrors = {}
  if (!fields.firstName.trim()) errors.firstName = 'errorFirstNameRequired'
  else if (fields.firstName.trim().length > 64) errors.firstName = 'errorFirstNameTooLong'
  if (!fields.lastName.trim()) errors.lastName = 'errorLastNameRequired'
  else if (fields.lastName.trim().length > 64) errors.lastName = 'errorLastNameTooLong'
  if (!fields.email.trim()) errors.email = 'errorEmailRequired'
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fields.email.trim())) {
    errors.email = 'errorEmailInvalid'
  }
  if (!fields.username.trim()) errors.username = 'errorUsernameRequired'
  else if (!usernamePattern.test(fields.username.trim().toLowerCase())) {
    errors.username = 'errorUsernameInvalid'
  }
  if (!fields.password) errors.password = 'errorPasswordRequired'
  else if (fields.password.length < 8) errors.password = 'errorPasswordTooShort'
  else if (fields.password.length > 128) errors.password = 'errorPasswordTooLong'
  else if (fields.password.toLowerCase().includes(fields.username.trim().toLowerCase())) {
    errors.password = 'errorPasswordContainsUsername'
  }
  if (!fields.confirmPassword) errors.confirmPassword = 'errorConfirmPasswordRequired'
  else if (fields.confirmPassword !== fields.password) {
    errors.confirmPassword = 'errorConfirmPasswordMismatch'
  }
  return errors
}

export function validateEdit(
  fields: Pick<UserFields, 'firstName' | 'lastName' | 'email' | 'phone'>,
): FieldErrors {
  const errors: FieldErrors = {}
  if (!fields.firstName.trim()) errors.firstName = 'errorFirstNameRequired'
  else if (fields.firstName.trim().length > 64) errors.firstName = 'errorFirstNameTooLong'
  if (fields.lastName.trim().length > 64) errors.lastName = 'errorLastNameTooLong'
  if (!fields.email.trim()) errors.email = 'errorEmailRequired'
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(fields.email.trim())) {
    errors.email = 'errorEmailInvalid'
  }
  const phone = fields.phone.trim()
  if (phone && (phone.length > 32 || !/^[0-9+()\-. ]+$/.test(phone))) {
    errors.phone = 'errorPhoneInvalid'
  }
  return errors
}

export type SetPasswordFields = { password: string; confirmPassword: string }

export function validateSetPassword(
  fields: SetPasswordFields,
  username: string,
): FieldErrors {
  const errors: FieldErrors = {}
  if (!fields.password) errors.password = 'errorPasswordRequired'
  else if (fields.password.length < 8) errors.password = 'errorPasswordTooShort'
  else if (fields.password.length > 128) errors.password = 'errorPasswordTooLong'
  else if (fields.password.toLowerCase().includes(username.toLowerCase())) {
    errors.password = 'errorPasswordContainsUsername'
  }
  if (!fields.confirmPassword) errors.confirmPassword = 'errorConfirmPasswordRequired'
  else if (fields.confirmPassword !== fields.password) {
    errors.confirmPassword = 'errorConfirmPasswordMismatch'
  }
  return errors
}

export function hasFieldErrors(errors: FieldErrors): boolean {
  return Object.keys(errors).length > 0
}
