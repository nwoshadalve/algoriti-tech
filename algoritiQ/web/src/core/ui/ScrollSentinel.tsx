/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useEffect, useRef } from 'react'

type ScrollSentinelProps = {
  /** The sentinel came into (or near) view: load the next page. */
  onReach: () => void
  /** Nothing more to load, or already loading. */
  disabled?: boolean
}

/** An invisible marker below a list: when scrolling brings it close, the next page is asked for. */
export function ScrollSentinel({ onReach, disabled = false }: ScrollSentinelProps) {
  const marker = useRef<HTMLDivElement>(null)
  const latest = useRef(onReach)

  useEffect(() => {
    latest.current = onReach
  })

  useEffect(() => {
    const element = marker.current
    if (disabled || !element || typeof IntersectionObserver === 'undefined') return
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) latest.current()
      },
      { rootMargin: '240px 0px' },
    )
    observer.observe(element)
    return () => observer.disconnect()
  }, [disabled])

  return <div ref={marker} aria-hidden="true" data-testid="scroll-sentinel" className="h-px w-full" />
}
