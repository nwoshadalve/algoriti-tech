import { createBrowserRouter } from 'react-router-dom'
import { appRoutes } from '@/app/appRoutes'
import { routerBasename } from '@/app/routerBasename'

export const router = createBrowserRouter(appRoutes, {
  basename: routerBasename(import.meta.env.BASE_URL, document.baseURI),
})
