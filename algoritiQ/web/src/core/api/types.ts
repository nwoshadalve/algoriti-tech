/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
export type Role = 'admin' | 'receptionist'

export type Account = {
  id: string
  username: string
  displayName: string
  email: string
  firstName: string
  lastName: string
  phone: string
  /** 0 when there is no photo; changes whenever the photo does. */
  photoVersion: number
  role: 'admin' | 'receptionist'
}

export type ManagedUser = Account & {
  status: 'active' | 'inactive'
  scopeIds: string[]
  /** ISO date-time. */
  createdAt: string
}

export type UserSort = 'name' | 'username' | 'role' | 'status' | 'created'

/** What the users table asks the tablet for. The tablet does all of it. */
export type UsersQuery = {
  search: string
  role: Role | ''
  status: 'active' | 'inactive' | ''
  sort: UserSort
  dir: 'asc' | 'desc'
}

export type UsersPageResult = {
  users: ManagedUser[]
  /** Everything that matched, not only this page. */
  total: number
  /** Pass back to get the next page; null on the last one. */
  nextCursor: string | null
}

export type UsersContextTarget = {
  id: string
  name: string
}

export type UsersContext = {
  licenseType: 'doctor' | 'chamber' | null
  assignmentTarget: 'chamber' | 'doctor'
  targets: UsersContextTarget[]
  onboarding: {
    needsAttention: boolean
  }
}

export type CreateUserInput = {
  role: Role
  username: string
  firstName: string
  lastName: string
  email: string
  password: string
  scopeIds: string[]
}

export type UpdateUserInput = {
  firstName: string
  lastName: string
  email: string
  phone: string
  status?: 'active' | 'inactive'
  scopeIds?: string[]
}

export type ProfileInput = {
  firstName: string
  lastName: string
  email: string
  phone: string
}

export type LoginResult = {
  token: string
  /** ISO date-time. */
  expiresAt: string
  account: Account
}

export type ResetStartResult = {
  /** One-time ticket for the second step. */
  resetToken: string
  /** ISO date-time. */
  expiresAt: string
}

export type SetupStatus = {
  adminRegistered: boolean
  claimCodeRequired: boolean
}

export type RegisterAdminRequest = {
  claimCode: string
  username: string
  firstName: string
  lastName: string
  email: string
  password: string
}

export type ApiErrorBody = {
  error: {
    code: string
    message: string
    attemptsLeft?: number
  }
}

export type LicenseType = 'doctor' | 'chamber'

export type Doctor = {
  id: string
  name: string
  degrees: string[]
  designation: string
  workplace: string
  registrationNumber: string
  specialty: string
  /** 0 when there is no photo; changes whenever the photo does. */
  photoVersion: number
}

export type DoctorInput = Omit<Doctor, 'id' | 'photoVersion'>

export type LicenseStatus = 'active' | 'grace' | 'expired'

export type LicenseSummary = {
  type: LicenseType
  maxDoctors: number
  maxChambers: number
  chambersUsed: number
  /** ISO date-time. */
  issuedAt: string
  /** ISO date-time; null for a license with no end date. */
  expiresAt: string | null
  status: LicenseStatus
}

export type Chamber = {
  id: string
  name: string
  location: string
  phone: string
}

export type ChamberInput = Omit<Chamber, 'id'>

export type PinDevice = {
  id: string
  /** Which browser, as named when the PIN was set. */
  label: string
  /** ISO date-time. */
  createdAt: string
  /** ISO date-time; null when never used. */
  lastUsedAt: string | null
}
