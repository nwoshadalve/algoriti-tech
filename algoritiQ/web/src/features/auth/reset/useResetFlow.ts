/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ApiError } from '@/core/api/client'
import { finishPasswordReset, startPasswordReset } from '@/core/api/auth'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
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
  const { t, locale } = useLocale()
  const { signOut } = useAuth()
  const navigate = useNavigate()
  const toast = useToast()

  const [step, setStep] = useState<ResetStep>(1)
  const [username, setUsername] = useState('')
  const [ticket, setTicket] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  function fail(cause: unknown) {
    const { key, params } = authError(cause, locale)
    toast.error(t(key, params))
  }

  function submitUsername(value: string) {
    setUsername(value.trim())
    setStep(2)
  }

  async function submitKey(activationKey: string) {
    setBusy(true)
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
    try {
      await finishPasswordReset(ticket, newPassword)
      // The tablet ended every sign-in of the account; forget this one too.
      await signOut()
      toast.success(t('noticePasswordReset'))
      navigate('/login', { replace: true })
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
    if (step === 3) setTicket(null)
    setStep((current) => (current > 1 ? ((current - 1) as ResetStep) : current))
  }

  return { step, username, busy, submitUsername, submitKey, submitPassword, back }
}
