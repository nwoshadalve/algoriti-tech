/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
let locks = 0

function scrollbarWidth(): number {
  return window.innerWidth - document.documentElement.clientWidth
}

/** Stops the page behind a popup from scrolling. Several popups can hold it at once. */
export function lockPageScroll(): () => void {
  if (locks++ === 0) {
    const gap = scrollbarWidth()
    if (gap > 0) document.body.style.paddingRight = `${gap}px`
    document.body.classList.add('overflow-hidden')
  }
  let released = false
  return () => {
    if (released) return
    released = true
    if (--locks === 0) {
      document.body.classList.remove('overflow-hidden')
      document.body.style.paddingRight = ''
    }
  }
}
