/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ButtonHTMLAttributes, ReactNode } from 'react'
import { BrandLoader } from '@/core/ui/BrandLoader'

type LoadingButtonProps = {
  isLoading?: boolean
  loadingLabel?: string
  children: ReactNode
} & ButtonHTMLAttributes<HTMLButtonElement>

/**
 * Primary action that keeps its size and shows [BrandLoader] while loading.
 * Matches Flutter `LoadingButton`.
 */
export function LoadingButton({
  isLoading = false,
  loadingLabel,
  children,
  className = '',
  disabled,
  type = 'button',
  ...rest
}: LoadingButtonProps) {
  const isDisabled = disabled || isLoading

  return (
    <button
      type={type}
      disabled={isDisabled}
      className={[
        'relative min-h-12 w-full rounded-lg bg-brand-coral-action px-4 py-3 text-base font-semibold text-white shadow-sm transition-opacity',
        'hover:opacity-95 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brand-coral',
        'disabled:cursor-not-allowed disabled:opacity-60',
        className,
      ]
        .filter(Boolean)
        .join(' ')}
      aria-busy={isLoading}
      {...rest}
    >
      <span className={isLoading ? 'invisible' : undefined} aria-hidden={isLoading}>
        {children}
      </span>
      {isLoading ? (
        <span className="absolute inset-0 flex items-center justify-center">
          <BrandLoader
            dotSize={8}
            litColor="#ffffff"
            idleColor="rgba(255,255,255,0.45)"
            semanticLabel={loadingLabel}
          />
        </span>
      ) : null}
    </button>
  )
}
