/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { sendTokenPrint } from '@/core/api/queueDesk'
import type { IssuedTokenResult } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'
import { readSession } from '@/features/auth/session'
import { boardErrorKey } from '@/features/board/boardErrors'

type Toast = { success: (msg: string) => void; error: (msg: string) => void }

/** Refresh the desk, try printing the new slip, refresh again — same order as the tablet. */
export async function afterDeskIssue(
  issued: IssuedTokenResult,
  refresh: () => void | Promise<void>,
  toast: Toast,
  t: (key: MessageKey) => string,
): Promise<void> {
  await refresh()
  const token = readSession()
  if (!token) return
  try {
    await sendTokenPrint(token, issued.token.id, issued.printAttemptId)
    toast.success(t('boardPatientAddedPrinted'))
  } catch (error) {
    toast.error(t(boardErrorKey(error)))
  }
  await refresh()
}
