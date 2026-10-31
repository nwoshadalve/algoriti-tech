/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect } from 'react'
import { subscribeLiveEvent } from '@/core/api/liveEvents'
import { queryClient } from '@/core/query/queryClient'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { useToast } from '@/core/toast/toastContext'
import { queueQueryKeys } from '@/features/queue/queueQueryKeys'
import { shouldShowQueueConfigurationLiveToast } from '@/features/queue/queueLocalChange'

/** Invalidates TanStack Query cache when the tablet publishes queue config changes. */
export function useQueueLiveQuerySync() {
  const { t } = useLocale()
  const toast = useToast()

  useEffect(() => {
    return subscribeLiveEvent((name, payload) => {
      if (name !== 'queue.configuration.changed') return
      const scope = payload.scope
      if (scope === 'clinic') {
        void queryClient.invalidateQueries({ queryKey: queueQueryKeys.all })
        if (shouldShowQueueConfigurationLiveToast()) {
          toast.success(t('queueConfigUpdatedLive'))
        }
        return
      }
      if (scope === 'chamber' && typeof payload.chamberId === 'string') {
        void queryClient.invalidateQueries({
          queryKey: queueQueryKeys.chamber(payload.chamberId),
        })
      }
    })
  }, [t, toast])
}
