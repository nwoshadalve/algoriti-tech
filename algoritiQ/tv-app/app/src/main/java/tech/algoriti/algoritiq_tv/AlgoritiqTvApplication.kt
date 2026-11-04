/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject
import tech.algoriti.algoritiq_tv.features.shell.application.TvConnection
import timber.log.Timber

@HiltAndroidApp
class AlgoritiqTvApplication : Application() {
    @Inject lateinit var connection: TvConnection

    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.DEBUG) {
            Timber.plant(Timber.DebugTree())
        }
        // The link to the tablet belongs to the app, not to a screen.
        connection.start()
    }
}
