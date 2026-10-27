import { useTheme } from '@/core/theme/ThemeProvider'

type BrandWordmarkProps = {
  height?: number
  className?: string
}

/**
 * Wordmark drawn like the Flutter [BrandLogo.wordmark]: ink follows theme brightness
 * (navy on light, white on dark). Coral Q stays #FF5C39.
 */
export function BrandWordmark({ height = 28, className }: BrandWordmarkProps) {
  const { resolved } = useTheme()
  const ink = resolved === 'dark' ? '#FFFFFF' : '#0B1F3A'
  const width = height * (370 / 100)

  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 370 100"
      width={width}
      height={height}
      className={className}
      role="img"
      aria-label="AlgoritiQ"
    >
      <rect x="8" y="14" width="56" height="20" rx="6" fill={ink} />
      <rect x="26" y="40" width="56" height="20" rx="6" fill="#FF5C39" />
      <rect x="8" y="66" width="56" height="20" rx="6" fill={ink} />
      <text
        x="100"
        y="66"
        fill={ink}
        fontFamily="'Plus Jakarta Sans', system-ui, sans-serif"
        fontSize="46"
        fontWeight="700"
        letterSpacing="-1.5"
      >
        Algoriti
        <tspan fill="#FF5C39">Q</tspan>
      </text>
    </svg>
  )
}
