/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.app.Application
import android.content.Context
import android.os.Build

/**
 * Keeps all app data (database, photos, settings, Keystore-wrapped secrets) in
 * device-protected storage, so the local API can start after a restart
 * before anyone unlocks a PIN-locked tablet (Android "Direct Boot").
 *
 * Device-protected storage is still encrypted, but with a key tied to the
 * device rather than to the PIN. Plugins use the application context, so
 * changing it here moves every file they write.
 */
class AlgoritiqApplication : Application() {
    override fun attachBaseContext(base: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            super.attachBaseContext(base)
            return
        }
        DeviceStorage.credentialContext = base
        super.attachBaseContext(base.createDeviceProtectedStorageContext())
    }
}
