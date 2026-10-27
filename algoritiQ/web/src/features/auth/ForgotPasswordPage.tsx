import { SetupLayout } from '@/app/SetupLayout'
import { NoticeBanner } from '@/core/ui/NoticeBanner'
import { SetupCard } from '@/core/ui/SetupCard'
import { StepAside } from '@/core/ui/StepAside'
import { StepStrip } from '@/core/ui/StepStrip'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { KeyStep, PasswordStep, UsernameStep } from '@/features/auth/reset/ResetSteps'
import { useResetFlow } from '@/features/auth/reset/useResetFlow'
/** Forgotten admin password: username, activation key, new password. */
export function ForgotPasswordPage() {
  const { t } = useLocale()
  const flow = useResetFlow()

  const steps = [t('resetStepUsername'), t('resetStepKey'), t('resetStepPassword')]

  return (
    <SetupLayout
      aside={
        <StepAside
          title={t('resetAsideTitle')}
          intro={t('resetAsideIntro')}
          steps={steps}
          activeStep={flow.step}
        />
      }
      mobileHeader={<StepStrip label={t('resetProgressLabel')} steps={steps} activeStep={flow.step} />}
    >
      <SetupCard labelledBy="reset-heading">
          {flow.error ? <NoticeBanner>{flow.error}</NoticeBanner> : null}
          {flow.step === 1 ? (
            <UsernameStep initial={flow.username} onSubmit={flow.submitUsername} />
          ) : null}
          {flow.step === 2 ? (
            <KeyStep busy={flow.busy} onSubmit={flow.submitKey} onBack={flow.back} />
          ) : null}
          {flow.step === 3 ? (
            <PasswordStep
              username={flow.username}
              busy={flow.busy}
              onSubmit={flow.submitPassword}
              onBack={flow.back}
            />
          ) : null}
        </SetupCard>
    </SetupLayout>
  )
}
