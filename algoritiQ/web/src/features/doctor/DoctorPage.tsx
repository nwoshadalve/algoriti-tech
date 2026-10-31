/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useState, type FormEvent } from 'react'
import { Navigate } from 'react-router-dom'
import { ApiError } from '@/core/api/client'
import {
  fetchDoctorPhoto,
  getDoctor,
  removeDoctorPhoto,
  saveDoctor,
  uploadDoctorPhoto,
} from '@/core/api/doctor'
import type { Doctor } from '@/core/api/types'
import { useClinic } from '@/core/clinic/clinicContext'
import { useLocale } from '@/core/i18n/LocaleProvider'
import type { MessageKey } from '@/core/i18n/messages/types'
import { useToast } from '@/core/toast/toastContext'
import { Card } from '@/core/ui/Card'
import { UndoIcon } from '@/core/ui/icons'
import { IconButton } from '@/core/ui/IconButton'
import { LoadingButton } from '@/core/ui/LoadingButton'
import { PageHeader } from '@/core/ui/PageHeader'
import { PagePreloader } from '@/core/ui/PagePreloader'
import { TextField } from '@/core/ui/TextField'
import { readSession } from '@/features/auth/session'
import { doctorQueryKeys } from '@/features/doctor/doctorQueryKeys'
import { avatarQueryKeys } from '@/core/query/avatarQueryKeys'
import { dropAvatarObjectUrls } from '@/core/ui/avatarObjectUrlCache'
import {
  parseDegrees,
  validateDoctor,
  type DoctorErrors,
} from '@/features/doctor/doctorValidation'
import { PhotoCard } from '@/features/settings/PhotoCard'

type Fields = {
  name: string
  degrees: string
  designation: string
  workplace: string
  registrationNumber: string
  specialty: string
}

const fieldsOf = (doctor: Doctor): Fields => ({
  name: doctor.name,
  degrees: doctor.degrees.join(', '),
  designation: doctor.designation,
  workplace: doctor.workplace,
  registrationNumber: doctor.registrationNumber,
  specialty: doctor.specialty,
})

function requireSessionToken(): string {
  const token = readSession()
  if (!token) throw new Error('signed_out')
  return token
}

/** The doctor of a doctor license: details and photo, as shown to patients. */
export function DoctorPage() {
  const { t } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const { licenseType } = useClinic()
  const queriesEnabled = licenseType === 'doctor'

  const doctorQuery = useQuery({
    queryKey: doctorQueryKeys.detail(),
    queryFn: async () => getDoctor(requireSessionToken()),
    enabled: queriesEnabled,
    retry: false,
  })

  useEffect(() => {
    if (!doctorQuery.isError) return
    toast.error(t('doctorLoadFailed'))
  }, [doctorQuery.isError, t, toast])

  // A clinic that is not licensed for one doctor has no such page.
  if (licenseType === null || licenseType === 'chamber') return <Navigate to="/home" replace />

  const doctor = doctorQuery.data
  const loading = doctorQuery.isPending && doctor === undefined
  const failed = doctorQuery.isError && doctor === undefined

  return (
    <div>
      <PageHeader title={t('navDoctor')} description={t('doctorIntro')} />
      {failed ? (
        <Card className="text-center text-sm">{t('doctorLoadFailed')}</Card>
      ) : loading || !doctor ? (
        <PagePreloader label={t('loadingLabel')} />
      ) : (
        <div className="grid gap-6 lg:grid-cols-[minmax(0,20rem)_minmax(0,1fr)] lg:items-start">
          <PhotoCard
            title={t('doctorPhotoTitle')}
            photoScope="doctor"
            person={{
              firstName: doctor.name,
              displayName: doctor.name,
              username: '',
              photoVersion: doctor.photoVersion,
            }}
            source={fetchDoctorPhoto}
            onUpload={async (square) => {
              const updated = await uploadDoctorPhoto(requireSessionToken(), square)
              dropAvatarObjectUrls('doctor')
              void queryClient.invalidateQueries({ queryKey: [...avatarQueryKeys.all, 'doctor'] })
              queryClient.setQueryData(doctorQueryKeys.detail(), updated)
            }}
            onRemove={async () => {
              const updated = await removeDoctorPhoto(requireSessionToken())
              dropAvatarObjectUrls('doctor')
              void queryClient.invalidateQueries({ queryKey: [...avatarQueryKeys.all, 'doctor'] })
              queryClient.setQueryData(doctorQueryKeys.detail(), updated)
            }}
          />
          <DetailsCard doctor={doctor} />
        </div>
      )}
    </div>
  )
}

function DetailsCard({ doctor }: { doctor: Doctor }) {
  const { t } = useLocale()
  const toast = useToast()
  const queryClient = useQueryClient()
  const saved = fieldsOf(doctor)
  const [fields, setFields] = useState<Fields>(saved)
  const [errors, setErrors] = useState<DoctorErrors>({})
  const [busy, setBusy] = useState(false)

  const dirty = (Object.keys(saved) as (keyof Fields)[]).some((key) => fields[key].trim() !== saved[key])

  function set(key: keyof Fields, value: string) {
    setFields((current) => ({ ...current, [key]: value }))
    setErrors((current) => ({ ...current, [key]: undefined }))
  }

  async function onSubmit(event: FormEvent) {
    event.preventDefault()
    if (busy) return
    const found = validateDoctor(fields)
    setErrors(found)
    if (Object.keys(found).length > 0) {
      toast.error(t('errorFixFields'))
      return
    }

    setBusy(true)
    try {
      const updated = await saveDoctor(requireSessionToken(), {
        name: fields.name.trim(),
        degrees: parseDegrees(fields.degrees),
        designation: fields.designation.trim(),
        workplace: fields.workplace.trim(),
        registrationNumber: fields.registrationNumber.trim(),
        specialty: fields.specialty.trim(),
      })
      queryClient.setQueryData(doctorQueryKeys.detail(), updated)
      setFields(fieldsOf(updated))
      toast.success(t('doctorSaved'))
    } catch (error) {
      const code = error instanceof ApiError ? error.code : ''
      const key: MessageKey | null =
        code === 'doctor_name_missing'
          ? 'doctorErrorName'
          : code === 'doctor_too_long'
            ? 'doctorErrorTooLong'
            : code === 'doctor_too_many_degrees'
              ? 'doctorErrorDegrees'
              : null
      if (key) {
        setErrors({ [code === 'doctor_name_missing' || code === 'doctor_too_long' ? 'name' : 'degrees']: key })
        toast.error(t(key))
      } else {
        toast.error(t(error instanceof TypeError ? 'errorNetwork' : 'errorGeneric'))
      }
    } finally {
      setBusy(false)
    }
  }

  const error = (key: keyof DoctorErrors) => {
    const message = errors[key]
    return message ? t(message) : undefined
  }

  return (
    <Card as="section" labelledBy="doctor-details">
      <h2 id="doctor-details" className="text-lg font-semibold">
        {t('doctorDetailsTitle')}
      </h2>
      <form className="mt-6 space-y-5" onSubmit={(event) => void onSubmit(event)} noValidate>
        <TextField
          id="doctor-name"
          label={t('fieldDoctorName')}
          autoComplete="off"
          value={fields.name}
          error={error('name')}
          onChange={(event) => set('name', event.target.value)}
        />
        <TextField
          id="doctor-degrees"
          label={t('fieldDegrees')}
          hint={t('fieldDegreesHint')}
          autoComplete="off"
          value={fields.degrees}
          error={error('degrees')}
          onChange={(event) => set('degrees', event.target.value)}
        />
        <div className="grid gap-5 sm:grid-cols-2">
          <TextField
            id="doctor-specialty"
            label={t('fieldSpecialty')}
            autoComplete="off"
            value={fields.specialty}
            error={error('specialty')}
            onChange={(event) => set('specialty', event.target.value)}
          />
          <TextField
            id="doctor-designation"
            label={t('fieldDesignation')}
            autoComplete="off"
            value={fields.designation}
            error={error('designation')}
            onChange={(event) => set('designation', event.target.value)}
          />
        </div>
        <TextField
          id="doctor-workplace"
          label={t('fieldWorkplace')}
          autoComplete="off"
          value={fields.workplace}
          error={error('workplace')}
          onChange={(event) => set('workplace', event.target.value)}
        />
        <TextField
          id="doctor-registration"
          label={t('fieldRegistration')}
          autoComplete="off"
          value={fields.registrationNumber}
          error={error('registrationNumber')}
          onChange={(event) => set('registrationNumber', event.target.value)}
        />
        <div className="flex items-center justify-end gap-2 pt-1">
          <IconButton
            label={t('doctorDiscard')}
            icon={UndoIcon}
            disabled={busy || !dirty}
            onClick={() => {
              setFields(saved)
              setErrors({})
            }}
          />
          <LoadingButton
            type="submit"
            isLoading={busy}
            loadingLabel={t('settingsSaving')}
            disabled={!dirty}
            className="sm:w-auto sm:min-w-44"
          >
            {t('settingsSave')}
          </LoadingButton>
        </div>
      </form>
    </Card>
  )
}
