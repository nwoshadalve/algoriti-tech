/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { PagePreloader } from '@/core/ui/PagePreloader'

/** Full-screen wait while session, work scope, or clinic context is still settling. */
export function BootstrapScreen() {
  return (
    <div className="flex min-h-dvh items-center justify-center bg-brand-mist dark:bg-brand-navy">
      <PagePreloader className="py-10" />
    </div>
  )
}
