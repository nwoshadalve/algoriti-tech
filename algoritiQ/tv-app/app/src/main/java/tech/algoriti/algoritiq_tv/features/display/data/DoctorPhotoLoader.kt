/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.data

import android.graphics.BitmapFactory
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import tech.algoriti.algoritiq_tv.core.network.ApiConfig
import tech.algoriti.algoritiq_tv.core.network.ClinicTls
import timber.log.Timber

/** Fetches the doctor's photo from the tablet over the same secure connection as everything else. */
@Singleton
class DoctorPhotoLoader
    @Inject
    constructor(
        okHttpClient: OkHttpClient,
        private val config: ApiConfig,
    ) {
        private val client = ClinicTls.selfSigned(okHttpClient)

        /** The photo at [path] on the tablet, or null when it cannot be fetched or read. */
        suspend fun load(path: String): ImageBitmap? =
            withContext(Dispatchers.IO) {
                runCatching {
                    val request = Request.Builder().url(ApiConfig.absoluteUrl(config.defaultHost, path)).build()
                    client.newCall(request).execute().use { response ->
                        if (!response.isSuccessful) return@use null
                        decode(response.body?.bytes() ?: return@use null)
                    }
                }.onFailure { Timber.w(it, "doctor_photo_failed") }.getOrNull()
            }

        /** Decodes at about the size shown, so a large photo does not fill the TV's memory. */
        private fun decode(bytes: ByteArray): ImageBitmap? {
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
            var sample = 1
            while (bounds.outWidth / (sample * 2) >= MAX_SIDE && bounds.outHeight / (sample * 2) >= MAX_SIDE) sample *= 2
            val options = BitmapFactory.Options().apply { inSampleSize = sample }
            return BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)?.asImageBitmap()
        }

        private companion object {
            const val MAX_SIDE = 480
        }
    }
