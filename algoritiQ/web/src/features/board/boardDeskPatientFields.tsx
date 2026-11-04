/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import type { PatientGender } from '@/core/api/types'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { SelectField } from '@/core/ui/SelectField'
import { TextField } from '@/core/ui/TextField'

const genderOptions: {
  value: PatientGender | ''
  labelKey: 'boardGenderMale' | 'boardGenderFemale' | 'boardGenderOther' | 'boardGenderNotStated'
}[] = [
  { value: 'male', labelKey: 'boardGenderMale' },
  { value: 'female', labelKey: 'boardGenderFemale' },
  { value: 'other', labelKey: 'boardGenderOther' },
  { value: 'not_stated', labelKey: 'boardGenderNotStated' },
]

export type BoardDeskPatientFieldsProps = {
  bengaliName: string
  englishName: string
  phone: string
  age: string
  gender: PatientGender | ''
  onBengaliNameChange: (value: string) => void
  onEnglishNameChange: (value: string) => void
  onPhoneChange: (value: string) => void
  onAgeChange: (value: string) => void
  onGenderChange: (value: PatientGender | '') => void
  disabled?: boolean
  showErrors?: boolean
}

/** Patient name, phone, age, and gender — same field set as the tablet desk dialogs. */
export function BoardDeskPatientFields({
  bengaliName,
  englishName,
  phone,
  age,
  gender,
  onBengaliNameChange,
  onEnglishNameChange,
  onPhoneChange,
  onAgeChange,
  onGenderChange,
  disabled,
  showErrors,
}: BoardDeskPatientFieldsProps) {
  const { t } = useLocale()
  const required = (value: string) =>
    showErrors && value.trim() === '' ? t('boardFieldRequired') : undefined

  return (
    <div className="flex flex-col gap-4">
      <div className="grid gap-4 sm:grid-cols-2">
        <TextField
          id="desk-patient-bn"
          label={`${t('boardFieldBengaliName')} *`}
          value={bengaliName}
          onChange={(event) => onBengaliNameChange(event.target.value)}
          error={required(bengaliName)}
          disabled={disabled}
          autoComplete="name"
        />
        <TextField
          id="desk-patient-en"
          label={t('boardFieldEnglishName')}
          value={englishName}
          onChange={(event) => onEnglishNameChange(event.target.value)}
          disabled={disabled}
        />
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <TextField
          id="desk-patient-phone"
          label={`${t('fieldPhone')} *`}
          value={phone}
          onChange={(event) => onPhoneChange(event.target.value)}
          error={required(phone)}
          disabled={disabled}
          autoComplete="tel"
        />
        <TextField
          id="desk-patient-age"
          label={t('boardFieldAge')}
          value={age}
          onChange={(event) => onAgeChange(event.target.value)}
          inputMode="numeric"
          disabled={disabled}
        />
      </div>
      <SelectField
        id="desk-patient-gender"
        label={t('boardFieldGender')}
        value={gender === 'not_stated' ? '' : gender}
        onChange={(event) => onGenderChange((event.target.value as PatientGender) || '')}
        disabled={disabled}
        options={[
          { value: '', label: t('boardGenderUnset') },
          ...genderOptions.map((row) => ({ value: row.value, label: t(row.labelKey) })),
        ]}
      />
    </div>
  )
}
