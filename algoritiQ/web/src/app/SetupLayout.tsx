import { BrandWordmark } from '@/core/ui/BrandWordmark'
import { PageToolbar } from '@/core/ui/PageToolbar'
import type { ReactNode } from 'react'

type SetupLayoutProps = {
  children: ReactNode
  /** Beside the card from `lg` up. */
  aside?: ReactNode
  /** Above the card below `lg`, where the aside is hidden. */
  mobileHeader?: ReactNode
}

/**
 * The page frame: logo and toolbar on top, one card (with an optional aside
 * on wide screens). Built from 280 px up: the header
 * wraps instead of overflowing, padding grows with the screen, and the page
 * keeps clear of notches and the home bar.
 */
export function SetupLayout({ children, aside, mobileHeader }: SetupLayoutProps) {
  return (
    <div className="relative min-h-dvh overflow-x-clip bg-brand-mist text-brand-navy dark:bg-brand-navy dark:text-white">
      {/* A soft coral glow in the corner; decoration only. */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-x-0 top-0 h-80 bg-[radial-gradient(50rem_18rem_at_100%_0%,rgba(255,92,57,0.10),transparent)] dark:bg-[radial-gradient(50rem_18rem_at_100%_0%,rgba(255,92,57,0.16),transparent)]"
      />

      <header className="relative border-b border-brand-navy/8 px-4 pt-[max(0.75rem,env(safe-area-inset-top))] pb-3 dark:border-white/10 sm:px-6 lg:px-10 lg:py-5">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-x-4 gap-y-2">
          <BrandWordmark height={28} className="shrink-0 sm:hidden" />
          <BrandWordmark height={36} className="hidden shrink-0 sm:block lg:hidden" />
          <BrandWordmark height={52} className="hidden shrink-0 lg:block" />
          <PageToolbar />
        </div>
      </header>

      <main className="relative mx-auto w-full max-w-6xl px-4 pt-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] sm:px-6 sm:pt-8 lg:px-10 lg:pt-10">
        <div
          className={[
            'gap-10 lg:gap-14 xl:gap-20',
            aside ? 'lg:grid lg:grid-cols-[minmax(300px,1fr)_minmax(400px,520px)] lg:items-start' : '',
          ].join(' ')}
        >
          {aside ? <div className="hidden lg:block">{aside}</div> : null}
          <div className="mx-auto w-full min-w-0 max-w-md sm:max-w-xl lg:mx-0 lg:max-w-none">
            {mobileHeader}
            {children}
          </div>
        </div>
      </main>
    </div>
  )
}
