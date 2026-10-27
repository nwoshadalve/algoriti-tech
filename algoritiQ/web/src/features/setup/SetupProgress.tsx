import { useLocale } from '@/core/i18n/LocaleProvider'
import { StepStrip } from '@/core/ui/StepStrip'

type SetupProgressProps = {
  activeStep: 1 | 2 | 3
}

/** The progress strip of the admin setup, for screens without the step list. */
export function SetupProgress({ activeStep }: SetupProgressProps) {
  const { t } = useLocale()

  return (
    <StepStrip
      label={t('setupProgressLabel')}
      steps={[t('asideStepOpen'), t('asideStepCode'), t('asideStepRegister')]}
      activeStep={activeStep}
    />
  )
}
