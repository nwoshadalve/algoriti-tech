import { LanguageSwitcher } from '@/core/ui/LanguageSwitcher'
import { ThemeToggle } from '@/core/ui/ThemeToggle'

export function PageToolbar() {
  return (
    <div className="ml-auto flex shrink-0 items-center gap-2 sm:gap-3">
      <ThemeToggle />
      <div
        className="hidden h-7 w-px shrink-0 bg-brand-navy/20 sm:block dark:bg-white/20"
        aria-hidden="true"
      />
      <LanguageSwitcher />
    </div>
  )
}
