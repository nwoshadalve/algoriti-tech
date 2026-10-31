/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { CSSProperties } from 'react'
import './brand-loader.css'

type BrandLoaderProps = {
  /** Dot diameter in px (default 8). */
  dotSize?: number
  /** Lit dot colour (default: brand coral). */
  litColor?: string
  /** Idle dot colour. */
  idleColor?: string
  /** Screen reader label (e.g. localized "Loading…"). */
  semanticLabel?: string
  className?: string
}

/**
 * AlgoritiQ loading indicator: three dots light in turn (like queue tokens).
 * Use instead of spinners. Matches Flutter `BrandLoader`.
 */
export function BrandLoader({
  dotSize = 8,
  litColor,
  idleColor,
  semanticLabel,
  className = '',
}: BrandLoaderProps) {
  const style = {
    '--brand-loader-dot': `${dotSize}px`,
    ...(litColor ? { '--brand-loader-lit': litColor } : {}),
    ...(idleColor ? { '--brand-loader-idle': idleColor } : {}),
  } as CSSProperties

  return (
    <div
      className={['brand-loader', className].filter(Boolean).join(' ')}
      style={style}
      role="status"
      aria-live="polite"
      aria-label={semanticLabel}
      aria-busy="true"
    >
      <span className="brand-loader__dot" aria-hidden="true" />
      <span className="brand-loader__dot" aria-hidden="true" />
      <span className="brand-loader__dot" aria-hidden="true" />
    </div>
  )
}
