/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { Account } from '@/core/api/types'
import { useAvatarUrl, type PhotoSource } from '@/core/ui/useAvatarUrl'

type AvatarProps = {
  account: Pick<Account, 'firstName' | 'displayName' | 'username' | 'photoVersion'>
  size?: 'md' | 'xl'
  /** Where the picture comes from; the signed-in person's own by default. */
  source?: PhotoSource
  /** Separates TanStack Query cache entries when `source` is not the account photo. */
  photoScope?: string
  className?: string
}

const sizes = {
  md: 'h-10 w-10 text-base',
  xl: 'h-28 w-28 text-4xl sm:h-32 sm:w-32 sm:text-5xl',
}

/** Round picture of the person, or their first initial in capital when there is none. */
export function Avatar({ account, size = 'md', className = '', source, photoScope }: AvatarProps) {
  const url = useAvatarUrl(account.photoVersion, source, photoScope)
  const initial = (account.firstName || account.displayName || account.username)
    .trim()
    .charAt(0)
    .toLocaleUpperCase()

  return (
    <span
      data-testid="avatar"
      className={[
        'inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full bg-brand-coral-action font-bold text-white select-none',
        sizes[size],
        className,
      ].join(' ')}
    >
      {url ? (
        <img src={url} alt="" className="h-full w-full object-cover" />
      ) : (
        <span aria-hidden="true">{initial}</span>
      )}
    </span>
  )
}
