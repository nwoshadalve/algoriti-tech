/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Role } from '@/core/api/types'
import type { MessageKey } from '@/core/i18n/messages/types'

export const roleLabelKey: Record<Role, MessageKey> = {
  admin: 'roleAdmin',
  receptionist: 'roleReceptionist',
}
