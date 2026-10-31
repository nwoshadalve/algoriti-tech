/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { createBrowserRouter } from 'react-router-dom'
import { appRoutes } from '@/app/appRoutes'
import { routerBasename } from '@/app/routerBasename'

export const router = createBrowserRouter(appRoutes, {
  basename: routerBasename(import.meta.env.BASE_URL, document.baseURI),
})
