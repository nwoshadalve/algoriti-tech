import type { ReactNode } from 'react'

type NoticeBannerProps = {
  children: ReactNode
  /** An error (announced at once) or a plain notice. */
  tone?: 'error' | 'success'
}

/** A short message above a form: something went wrong, or went right. */
export function NoticeBanner({ children, tone = 'error' }: NoticeBannerProps) {
  const style =
    tone === 'error'
      ? 'border-amber-300/80 bg-amber-50 text-amber-950 dark:border-amber-500/40 dark:bg-amber-950/40 dark:text-amber-100'
      : 'border-emerald-300/80 bg-emerald-50 text-emerald-950 dark:border-emerald-500/40 dark:bg-emerald-950/40 dark:text-emerald-100'

  return (
    <div
      role={tone === 'error' ? 'alert' : 'status'}
      className={`mt-4 rounded-xl border px-3 py-2.5 text-sm ${style}`}
    >
      {children}
    </div>
  )
}
