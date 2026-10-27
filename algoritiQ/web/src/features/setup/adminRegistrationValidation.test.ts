import { describe, expect, it } from 'vitest'
import {
  hasFieldErrors,
  normalizeClaimCode,
  validateActivationCode,
  validateRegistration,
} from '@/features/setup/adminRegistrationValidation'

describe('normalizeClaimCode', () => {
  it('should strip spaces and dashes and uppercase', () => {
    expect(normalizeClaimCode('7k4m-9xq2')).toBe('7K4M9XQ2')
  })
})

describe('validateActivationCode', () => {
  it('should reject empty code', () => {
    expect(validateActivationCode('')).toBe('errorActivationCodeRequired')
  })

  it('should accept a normal code', () => {
    expect(validateActivationCode('7K4M-9XQ2')).toBeNull()
  })
})

describe('validateRegistration', () => {
  const valid = {
    firstName: 'Ada',
    lastName: 'Admin',
    email: 'ada@clinic.test',
    username: 'admin.clinic',
    password: 'long-enough',
    confirmPassword: 'long-enough',
  }

  it('should accept valid fields', () => {
    expect(hasFieldErrors(validateRegistration(valid))).toBe(false)
  })

  it('should reject password containing username', () => {
    const errors = validateRegistration({
      ...valid,
      username: 'clinic',
      password: 'clinic-secret',
      confirmPassword: 'clinic-secret',
    })
    expect(errors.password).toBe('errorPasswordContainsUsername')
  })

  it('should reject passwords shorter than 8 characters', () => {
    const errors = validateRegistration({
      ...valid,
      password: 'short',
      confirmPassword: 'short',
    })
    expect(errors.password).toBe('errorPasswordTooShort')
  })
})
