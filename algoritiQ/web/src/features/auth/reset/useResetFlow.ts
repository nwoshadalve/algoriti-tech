import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ApiError } from '@/core/api/client'
import { finishPasswordReset, startPasswordReset } from '@/core/api/auth'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { authError } from '@/features/auth/authErrors'
import { useAuth } from '@/features/auth/authContext'

export type ResetStep = 1 | 2 | 3

/**
 * The forgotten-password journey of an admin: username, then the tablet's
 * activation key (checked by the tablet, which hands back a one-time ticket),
 * then the new password. The first step asks nothing of the tablet, so it
 * never says whether the username exists; the key check does, with the same
 * answer for a wrong key and an unknown name.
 */
export function useResetFlow() {
  const { t } = useLocale()
  const { signOut } = useAuth()
  const navigate = useNavigate()

  const [step, setStep] = useState<ResetStep>(1)
  const [username, setUsername] = useState('')
  const [ticket, setTicket] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState<string | null>(null)

  function fail(cause: unknown) {
    const { key, params } = authError(cause)
    setError(t(key, params))
  }

  function submitUsername(value: string) {
    setUsername(value.trim())
    setError(null)
    setStep(2)
  }

  async function submitKey(activationKey: string) {
    setBusy(true)
    setError(null)
    try {
      const result = await startPasswordReset(username, activationKey)
      setTicket(result.resetToken)
      setStep(3)
    } catch (cause) {
      fail(cause)
    } finally {
      setBusy(false)
    }
  }

  async function submitPassword(newPassword: string) {
    if (!ticket) return
    setBusy(true)
    setError(null)
    try {
      await finishPasswordReset(ticket, newPassword)
      // The tablet ended every sign-in of the account; forget this one too.
      await signOut()
      navigate('/login', { replace: true, state: { passwordReset: true } })
    } catch (cause) {
      if (cause instanceof ApiError && cause.code === 'reset_token_invalid') {
        setTicket(null)
        setStep(2)
      }
      fail(cause)
    } finally {
      setBusy(false)
    }
  }

  /** One step back; going back from the password step drops the ticket. */
  function back() {
    setError(null)
    if (step === 3) setTicket(null)
    setStep((current) => (current > 1 ? ((current - 1) as ResetStep) : current))
  }

  return { step, username, busy, error, submitUsername, submitKey, submitPassword, back }
}
