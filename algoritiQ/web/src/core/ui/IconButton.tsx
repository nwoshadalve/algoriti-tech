/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { ComponentType, MouseEventHandler, SVGProps } from 'react'
import { Tooltip } from '@/core/ui/Tooltip'

type IconButtonProps = {
  /** The action, in a word or two. It is the tooltip and, unless [ariaLabel] is given, the accessible name. */
  label: string
  /** Fuller accessible name, e.g. the action and who it is for. */
  ariaLabel?: string
  icon: ComponentType<SVGProps<SVGSVGElement>>
  onClick?: MouseEventHandler<HTMLButtonElement>
  disabled?: boolean
  /** Why it is disabled; shown as the tooltip instead of [label]. */
  disabledReason?: string
  tone?: 'default' | 'danger'
  /** Below `md`, where there is no hover, show the label next to the icon. */
  labelOnSmall?: boolean
  type?: 'button' | 'submit'
}

const base =
  'inline-flex shrink-0 items-center justify-center gap-2 rounded-lg border text-sm font-semibold transition-colors focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none disabled:cursor-not-allowed disabled:opacity-50'

const tones = {
  default:
    'border-brand-navy/15 bg-white text-brand-navy hover:bg-brand-mist dark:border-white/20 dark:bg-transparent dark:text-white dark:hover:bg-white/10',
  danger:
    'border-red-300/70 bg-white text-red-700 hover:bg-red-50 dark:border-red-400/40 dark:bg-transparent dark:text-red-300 dark:hover:bg-red-950/40',
}

/**
 * A button that is only an icon, with a tooltip. For actions on a row or
 * beside a value (edit, disable, delete, upload). The main action of a page or
 * popup stays a labelled button.
 */
export function IconButton({
  label,
  ariaLabel,
  icon: Icon,
  onClick,
  disabled = false,
  disabledReason,
  tone = 'default',
  labelOnSmall = false,
  type = 'button',
}: IconButtonProps) {
  return (
    <Tooltip label={disabled && disabledReason ? disabledReason : label}>
      <button
        type={type}
        aria-label={ariaLabel ?? label}
        disabled={disabled}
        onClick={onClick}
        className={[
          base,
          tones[tone],
          labelOnSmall ? 'min-h-11 min-w-11 px-3 md:px-0' : 'min-h-11 min-w-11 md:min-h-10 md:min-w-10',
        ].join(' ')}
      >
        <Icon className="shrink-0" />
        {labelOnSmall ? (
          <span aria-hidden="true" className="md:hidden">
            {label}
          </span>
        ) : null}
      </button>
    </Tooltip>
  )
}
