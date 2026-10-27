import { normalizeClaimCode } from '@/features/setup/adminRegistrationValidation'

const STORAGE_KEY = 'algoritiq.setup.claimCode'
const VERIFIED_KEY = 'algoritiq.setup.claimVerified'

export function saveClaimCode(raw: string): void {
  sessionStorage.setItem(STORAGE_KEY, normalizeClaimCode(raw))
}

/** After the tablet API accepts the code; required to open registration. */
export function saveVerifiedClaimCode(raw: string): void {
  saveClaimCode(raw)
  sessionStorage.setItem(VERIFIED_KEY, '1')
}

export function isClaimCodeVerified(): boolean {
  return sessionStorage.getItem(VERIFIED_KEY) === '1' && readClaimCode() != null
}

export function readClaimCode(): string | null {
  const value = sessionStorage.getItem(STORAGE_KEY)
  return value && value.length > 0 ? value : null
}

export function clearClaimCode(): void {
  sessionStorage.removeItem(STORAGE_KEY)
  sessionStorage.removeItem(VERIFIED_KEY)
}
