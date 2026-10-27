export type Account = {
  id: string
  username: string
  displayName: string
  role: 'admin'
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
  password: string
  displayName?: string
}

export type ApiErrorBody = {
  error: {
    code: string
    message: string
    attemptsLeft?: number
  }
}
