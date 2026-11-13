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
  /** Digits-only prefix for new patient IDs in this chamber. */
  patientIdPrefix: string
  /** Next sequence appended to the prefix on register (resets when prefix changes). */
  patientIdNextSequence: number
}

export type ChamberInput = {
  name: string
  location: string
  phone: string
  /** Optional on PATCH; server assigns on POST. */
  patientIdPrefix?: string
}

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
  /** The patient's one name, in whatever language it was written. */
  name: string
  phoneNormalized: string
  gender?: PatientGender | null
  ageLabel?: string | null
  hasPaperFile?: boolean
  /** ISO date-time. */
  registeredAt?: string | null
  /** Tokens the patient has had, cancelled ones left out (patient list only). */
  visitCount?: number
  /** ISO date-time of the latest token, or null if none. */
  lastVisitAt?: string | null
}

export type PatientSort = 'registered' | 'name' | 'id' | 'phone' | 'visits' | 'lastVisit'

export type PatientListQuery = {
  search?: string
  /** A gender, or `unset` for patients with none stated. */
  gender?: PatientGender | 'unset'
  paperFileOnly?: boolean
  sort?: PatientSort
  ascending?: boolean
  limit?: number
  offset?: number
}

export type PatientListPage = {
  items: PatientSummary[]
  /** Patients matching the search and filters. */
  total: number
  /** Every registered patient (older tablet builds do not send it). */
  registeredTotal?: number
}

export type RegisterPatientInput = {
  commandId: string
  chamberId: string
  name: string
  phone: string
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

export type UpdatePatientInput = {
  name: string
  phone: string
  /** With a token of the open session, the fee on that token is changed too; null clears it. */
  tokenId?: string
  feeBdt?: number | null
  /** With 	okenId: the visit is free (any fee is dropped). */
  isFree?: boolean
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
  patientName: string
  status: TokenStatus
  /** ISO date-time. */
  issuedAt: string
  firstCalledAt?: string | null
  enteredAt?: string | null
  cancelledAt?: string | null
  cancelReason?: string | null
  feeBdt?: number | null
  /** A free visit: no fee is taken (older tablets send none). */
  isFree?: boolean
  latestPrintStatus?: PrintAttemptStatus | null
  /** False while the token is on the board as the next one but its call has not been announced yet. */
  announced?: boolean
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
  /** The newest call, kept for desks that know one call. */
  calledToken: BoardTokenView | null
  /** Every call going on now, one per queue at most, in the queues' order. */
  calledTokens: BoardTokenView[]
  queueControls: QueueTypeBoardControl[]
  tokens: BoardTokenView[]
  printerBusyTokenId: string | null
}

export type TokenSort = 'issued' | 'id' | 'name' | 'serial' | 'queue' | 'wait' | 'status'

export type SessionTokenQuery = {
  search?: string
  status?: TokenStatus
  queueTypeId?: string
  notPrintedOnly?: boolean
  sort?: TokenSort
  ascending?: boolean
  limit?: number
  offset?: number
}

export type TokenPage = {
  items: BoardTokenView[]
  total: number
  counts: Partial<Record<TokenStatus, number>>
}

export type IssuePreview = {
  patient: PatientSummary
  chamberName: string
  queueTypeId: string
  queueEnglishName: string
  queueBengaliName: string
  previewSerial: number
  feeBdt?: number | null
  isFree?: boolean
}

export type IssuedTokenResult = {
  token: BoardTokenView
  printAttemptId: string
  printStatus: PrintAttemptStatus
}

/** One queue session (today's or an earlier one) and what happened in it. */
export type SessionSummary = {
  id: string
  chamberId: string
  chamberName: string
  /** Local calendar day the session was opened for (YYYY-MM-DD). */
  businessDate: string
  status: string
  /** ISO date-times. */
  openedAt: string
  openedByName?: string | null
  closedAt?: string | null
  closedByName?: string | null
  /** Why an admin ended it by force; empty for a normal end. */
  closeReason?: string | null
  firstCalledAt?: string | null
  lastCalledAt?: string | null
  counts: Partial<Record<TokenStatus, number>>
  /** Fees in BDT of the tokens, cancelled ones left out (older tablets send none). */
  totalFeeBdt?: number
  /** Patients seen free, cancelled ones left out (older tablets send none). */
  freeCount?: number
}

export type SessionQueueStat = {
  queueTypeId: string
  englishName: string
  bengaliName: string
  counts: Partial<Record<TokenStatus, number>>
  feeBdt?: number
}

export type SessionDetail = {
  session: SessionSummary
  queues: SessionQueueStat[]
  /** Different patients who had a token. */
  patientCount?: number
  /** From issuing a token to its first call, over the tokens that were called. */
  averageWaitSeconds?: number | null
  longestWaitSeconds?: number | null
}

export type SessionHistoryPage = {
  items: SessionSummary[]
  total: number
  /** Chambers this person may look at. */
  chambers: { id: string; name: string }[]
}
