/**
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
import { Link } from 'react-router-dom'
import { useClinic } from '@/core/clinic/clinicContext'
import { useLocale } from '@/core/i18n/LocaleProvider'
import { Card } from '@/core/ui/Card'
import { PageHeader } from '@/core/ui/PageHeader'
import { useAuth } from '@/features/auth/authContext'

/** Clinic Wi‑Fi setup, roles, and where to find each dashboard area. */
export function HelpPage() {
  const { t } = useLocale()
  const { licenseType } = useClinic()
  const { state } = useAuth()
  const role = state.status === 'signedIn' ? state.account.role : null
  const isAdmin = role === 'admin'
  const doctorLicense = licenseType === 'doctor'

  return (
    <div>
      <PageHeader title={t('navHelp')} description={t('helpIntro')} />

      <div className="space-y-6">
        <Card as="section" labelledBy="help-connect">
          <h2 id="help-connect" className="text-lg font-semibold">
            {t('helpConnectTitle')}
          </h2>
          <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
            {t('helpConnectBody')}
          </p>
        </Card>

        <Card as="section" labelledBy="help-account">
          <h2 id="help-account" className="text-lg font-semibold">
            {t('helpAccountTitle')}
          </h2>
          <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
            {t('helpAccountBody')}
          </p>
          <p className="mt-3 text-sm">
            <Link
              to="/forgot-password"
              className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
            >
              {t('forgotPasswordLink')}
            </Link>
          </p>
        </Card>

        {isAdmin ? (
          <Card as="section" labelledBy="help-admin-nav">
            <h2 id="help-admin-nav" className="text-lg font-semibold">
              {t('helpAdminNavTitle')}
            </h2>
            <p className="mt-2 text-sm text-brand-navy/70 dark:text-white/70">{t('helpAdminNavIntro')}</p>
            <ul className="mt-4 space-y-2 text-sm">
              <li>
                <Link
                  to="/home"
                  className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                >
                  {t('navOverview')}
                </Link>
                <span className="text-brand-navy/60 dark:text-white/60"> — {t('helpLinkOverview')}</span>
              </li>
              <li>
                <Link
                  to="/users"
                  className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                >
                  {t('navUsers')}
                </Link>
                <span className="text-brand-navy/60 dark:text-white/60"> — {t('helpLinkUsers')}</span>
              </li>
              <li>
                <span className="font-medium">{t('navConf')}</span>
                <ul className="mt-1 space-y-1 border-l border-brand-navy/15 pl-4 dark:border-white/15">
                  {doctorLicense ? (
                    <li>
                      <Link
                        to="/config/doctor"
                        className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                      >
                        {t('navDoctor')}
                      </Link>
                    </li>
                  ) : null}
                  {doctorLicense ? (
                    <li>
                      <Link
                        to="/config/chamber"
                        className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                      >
                        {t('navChamber')}
                      </Link>
                    </li>
                  ) : null}
                  <li>
                    <Link
                      to="/config/queue"
                      className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                    >
                      {t('navQueue')}
                    </Link>
                  </li>
                </ul>
              </li>
              <li>
                <Link
                  to="/monitoring"
                  className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                >
                  {t('navMonitoring')}
                </Link>
              </li>
              <li>
                <Link
                  to="/audit"
                  className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                >
                  {t('navAudit')}
                </Link>
              </li>
              <li>
                <Link
                  to="/backup"
                  className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
                >
                  {t('navBackup')}
                </Link>
              </li>
            </ul>
          </Card>
        ) : (
          <Card as="section" labelledBy="help-desk">
            <h2 id="help-desk" className="text-lg font-semibold">
              {t('helpReceptionistTitle')}
            </h2>
            <p className="mt-2 text-sm leading-relaxed text-brand-navy/75 dark:text-white/75">
              {t('helpReceptionistBody')}
            </p>
            <p className="mt-3">
              <Link
                to="/board"
                className="font-medium text-brand-coral underline-offset-2 hover:underline focus-visible:rounded focus-visible:ring-2 focus-visible:ring-brand-coral focus-visible:outline-none"
              >
                {t('navBoard')}
              </Link>
            </p>
          </Card>
        )}
      </div>
    </div>
  )
}
