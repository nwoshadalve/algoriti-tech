/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useLocale } from '@/core/i18n/LocaleProvider'
import { StepAside } from '@/core/ui/StepAside'

type SetupAsideProps = {
  activeStep: 1 | 2 | 3
}

export function SetupAside({ activeStep }: SetupAsideProps) {
  const { t } = useLocale()

  return (
    <StepAside
      title={t('setupTitle')}
      intro={t('setupIntro')}
      steps={[t('asideStepOpen'), t('asideStepCode'), t('asideStepRegister')]}
      activeStep={activeStep}
    />
  )
}
