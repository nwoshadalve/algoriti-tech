/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, SVGProps } from 'react'
import type { ServiceId } from '@/core/api/monitoring'
import type { MessageKey } from '@/core/i18n/messages/types'
import { ActivityIcon, PlugIcon, PrinterIcon, ServerIcon, TvIcon } from '@/core/ui/icons'

export type ServiceMeta = {
  labelKey: MessageKey
  icon: ComponentType<SVGProps<SVGSVGElement>>
}

export const serviceMeta: Record<ServiceId, ServiceMeta> = {
  api: { labelKey: 'monitorApi', icon: ActivityIcon },
  websocket: { labelKey: 'monitorWebsocket', icon: PlugIcon },
  androidService: { labelKey: 'monitorAndroid', icon: ServerIcon },
  printer: { labelKey: 'monitorPrinter', icon: PrinterIcon },
  tv: { labelKey: 'monitorTv', icon: TvIcon },
}

/** POS printer and TV app — shown first on the monitoring page. */
export const priorityServiceOrder: ServiceId[] = ['printer', 'tv']

/** API and live channel — compact list below clinic devices. */
export const supportServiceOrder: ServiceId[] = ['api', 'websocket']

/** Legacy glance strip order (tests and docs). */
export const glanceOrder: ServiceId[] = ['printer', 'tv', 'websocket', 'androidService']
