/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'

/** `system` = follow OS; `light` / `dark` = user override from the icon toggle. */
export type ThemePreference = 'system' | 'light' | 'dark'

type ThemeContextValue = {
  preference: ThemePreference
  resolved: 'light' | 'dark'
  toggleTheme: () => void
}

const STORAGE_KEY = 'algoritiq.theme'

const ThemeContext = createContext<ThemeContextValue | null>(null)

function readStoredPreference(): ThemePreference {
  const stored = localStorage.getItem(STORAGE_KEY)
  if (stored === 'light' || stored === 'dark') {
    return stored
  }
  return 'system'
}

function resolveTheme(preference: ThemePreference): 'light' | 'dark' {
  if (preference === 'light' || preference === 'dark') {
    return preference
  }
  const media = window.matchMedia?.('(prefers-color-scheme: dark)')
  return media?.matches ? 'dark' : 'light'
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [preference, setPreference] = useState<ThemePreference>(() => readStoredPreference())
  const [resolved, setResolved] = useState<'light' | 'dark'>(() =>
    resolveTheme(readStoredPreference()),
  )

  const applyResolved = useCallback((next: 'light' | 'dark') => {
    setResolved(next)
    document.documentElement.classList.toggle('dark', next === 'dark')
    document.documentElement.style.colorScheme = next
  }, [])

  useEffect(() => {
    applyResolved(resolveTheme(preference))
  }, [preference, applyResolved])

  useEffect(() => {
    if (preference !== 'system') {
      return
    }
    const media = window.matchMedia?.('(prefers-color-scheme: dark)')
    if (!media?.addEventListener) {
      return
    }
    const onChange = () => applyResolved(media.matches ? 'dark' : 'light')
    media.addEventListener('change', onChange)
    return () => media.removeEventListener('change', onChange)
  }, [preference, applyResolved])

  const toggleTheme = useCallback(() => {
    const next = resolved === 'dark' ? 'light' : 'dark'
    localStorage.setItem(STORAGE_KEY, next)
    setPreference(next)
  }, [resolved])

  const value = useMemo(
    () => ({ preference, resolved, toggleTheme }),
    [preference, resolved, toggleTheme],
  )

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext)
  if (!ctx) {
    throw new Error('useTheme must be used within ThemeProvider')
  }
  return ctx
}
