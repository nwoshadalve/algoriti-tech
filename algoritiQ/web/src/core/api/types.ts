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
  /** Only this admin may set another admin's password. */
  firstAdminId: string
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

export type QueuePolicy = {
  timeZone: string
  dayBoundary: string
  autoStart: boolean
}

export type QueueTypeConfig = {
  id: string
  englishName: string
  bengaliName: string
  startNumber: number
  endNumber: number
  displayOrder: number
  enabled: boolean
}

export type ChamberQueueSettings = {
  useClinicDefaults: boolean
  dayBoundaryOverride: string | null
  autoStartOverride: boolean | null
}

export type QueueSessionStatus =
  | 'NOT_STARTED'
  | 'OPEN'
  | 'CLOSING'
  | 'CLOSED'
  | 'ROLLOVER_DUE'

export type QueueTypeUsage = {
  queueTypeId: string
  englishName: string
  bengaliName: string
  startNumber: number
  endNumber: number
  issuedCount: number
  nextNumber: number
  enabled: boolean
  capacity: number
}

export type QueueSession = {
  id: string
  chamberId: string
  businessDate: string
  status: QueueSessionStatus
  openedAt: string
  openedByAccountId: string | null
  usage: QueueTypeUsage[]
}

export type AuditLogEntry = {
  id: number
  occurredAt: string
  action: string
  category: string
  outcome: string
  actorDisplayName: string | null
  actorRole: string | null
  safeMetadata: Record<string, unknown>
  detail: string | null
}

export type AuditLogQuery = {
  offset?: number
  from?: string
  to?: string
  actionPrefix?: string
  outcome?: string
}

export type AuditLogPage = {
  entries: AuditLogEntry[]
  total: number
  nextOffset: number | null
}

export type PinDevice = {
  id: string
  /** Which browser, as named when the PIN was set. */
  label: string
  /** ISO date-time. */
  createdAt: string
  /** ISO date-time; null when never used. */
  lastUsedAt: string | null
}

export type TokenStatus = 'WAITING' | 'CALLED' | 'ENTERED' | 'SKIPPED' | 'CANCELLED'

export type PrintAttemptStatus = 'PENDING' | 'SENT' | 'FAILED' | 'UNKNOWN'

export type PatientGender = 'male' | 'female' | 'other' | 'not_stated'

export type PatientSummary = {
  id: string
  patientNumber: number
  clinicPatientId: string
  bengaliName: string
  englishName: string
  phoneNormalized: string
  gender?: PatientGender | null
  ageLabel?: string | null
}

export type RegisterPatientInput = {
  commandId: string
  bengaliName: string
  phone: string
  englishName?: string
  gender?: PatientGender | null
  dateOfBirthMs?: number | null
  birthYear?: number | null
  approximateAgeYears?: number | null
  locality?: string | null
  legacyFileNumber?: string | null
  adminNote?: string | null
  hasPaperFile?: boolean
  confirmDuplicatePhone?: boolean
}

export type BoardTokenView = {
  id: string
  serial: number
  queueTypeId: string
  queueEnglishName: string
  queueBengaliName: string
  patientId: string
  clinicPatientId: string
  patientBengaliName: string
  status: TokenStatus
  /** ISO date-time. */
  issuedAt: string
  firstCalledAt?: string | null
  enteredAt?: string | null
  feeBdt?: number | null
  latestPrintStatus?: PrintAttemptStatus | null
}

export type QueueTypeBoardControl = {
  queueTypeId: string
  englishName: string
  bengaliName: string
  waitingCount: number
  nextSerial: number
  canCallNext: boolean
  canRecall: boolean
}

export type BoardSnapshot = {
  chamberId: string
  chamberName: string
  sessionId: string | null
  sessionOpen: boolean
  calledToken: BoardTokenView | null
  queueControls: QueueTypeBoardControl[]
  tokens: BoardTokenView[]
  printerBusyTokenId: string | null
}

export type IssuePreview = {
  patient: PatientSummary
  chamberName: string
  queueTypeId: string
  queueEnglishName: string
  queueBengaliName: string
  previewSerial: number
  feeBdt?: number | null
}

export type IssuedTokenResult = {
  token: BoardTokenView
  printAttemptId: string
  printStatus: PrintAttemptStatus
}
