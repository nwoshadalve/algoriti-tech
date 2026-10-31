/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { describe, expect, it } from 'vitest'
import { routerBasename } from '@/app/routerBasename'

describe('routerBasename', () => {
  it('should be the root for the relative base the production build uses', () => {
    // The blank-screen bug: './' was handed to the router as "/./".
    expect(routerBasename('./', 'https://algoritiq.local:8443/')).toBe('/')
  })

  it('should be the root on every page of an app served at the root', () => {
    expect(routerBasename('./', 'https://algoritiq.local:8443/register')).toBe('/')
    expect(routerBasename('./', 'https://algoritiq.local:8443/forgot-password')).toBe('/')
    expect(routerBasename('./', 'http://localhost:4173/login')).toBe('/')
  })

  it('should keep an absolute base as it is', () => {
    expect(routerBasename('/', 'http://localhost:5173/')).toBe('/')
  })

  it('should follow an app served in a folder, without a trailing slash', () => {
    expect(routerBasename('/clinic/', 'https://host/clinic/register')).toBe('/clinic')
  })
})
