/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import android.os.Build
import java.net.InetAddress
import tech.algoriti.algoritiq_tv.BuildConfig

/**
 * The Android TV emulator is not on the clinic's Wi-Fi, so it cannot hear the tablet's multicast
 * answer. In a debug build running on an emulator, `algoritiq.local` is the host PC (`10.0.2.2`),
 * which forwards to the tablet. A real TV never takes this path.
 */
object DevClinicDns {
    private const val EMULATOR_HOST_LOOPBACK = "10.0.2.2"

    fun emulatorHost(): InetAddress? =
        if (BuildConfig.DEBUG && isEmulator()) InetAddress.getByName(EMULATOR_HOST_LOOPBACK) else null

    private fun isEmulator(): Boolean =
        Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.contains("emulator") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.HARDWARE.contains("goldfish")
}
