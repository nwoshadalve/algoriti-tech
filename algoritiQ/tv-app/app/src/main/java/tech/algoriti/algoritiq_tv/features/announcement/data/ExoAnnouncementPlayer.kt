/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.announcement.data

import android.content.Context
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.datasource.okhttp.OkHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import okhttp3.OkHttpClient
import tech.algoriti.algoritiq_tv.core.network.ClinicTls
import tech.algoriti.algoritiq_tv.features.announcement.domain.AnnouncementPlayer
import tech.algoriti.algoritiq_tv.features.announcement.domain.AnnouncementResult
import timber.log.Timber

/**
 * Plays the tablet's announcement clips. Each clip gets its own short-lived player that reads over
 * the same secure OkHttp connection as the live channel. Clips play
 * one at a time. The player must be used on the main thread, so playback hops there.
 */
@Singleton
class ExoAnnouncementPlayer
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
        private val okHttpClient: OkHttpClient,
    ) : AnnouncementPlayer {
        private val mutex = Mutex()
        private var lastAnnouncementId: String? = null

        @Volatile private var current: ExoPlayer? = null

        override suspend fun play(
            url: String,
            announcementId: String,
        ): AnnouncementResult =
            mutex.withLock {
                if (lastAnnouncementId == announcementId) {
                    Timber.d("announcement_dedupe id=%s", announcementId)
                    return AnnouncementResult.Skipped
                }
                lastAnnouncementId = announcementId
                withContext(Dispatchers.Main) {
                    withTimeoutOrNull(PLAY_TIMEOUT_MS) { playOnMain(url) }
                        ?: AnnouncementResult.Failed("timeout")
                }
            }

        private suspend fun playOnMain(url: String): AnnouncementResult {
            val source = OkHttpDataSource.Factory(ClinicTls.selfSigned(okHttpClient))
            val player =
                ExoPlayer
                    .Builder(context)
                    .setMediaSourceFactory(DefaultMediaSourceFactory(source))
                    .setAudioAttributes(
                        AudioAttributes
                            .Builder()
                            .setUsage(C.USAGE_MEDIA)
                            .setContentType(C.AUDIO_CONTENT_TYPE_SPEECH)
                            .build(),
                        true,
                    ).build()
            current = player
            return try {
                suspendCancellableCoroutine { cont ->
                    player.addListener(
                        object : Player.Listener {
                            override fun onPlaybackStateChanged(state: Int) {
                                if (state == Player.STATE_ENDED && cont.isActive) {
                                    cont.resume(AnnouncementResult.Played)
                                }
                            }

                            override fun onPlayerError(error: PlaybackException) {
                                Timber.w(error, "announcement_error")
                                if (cont.isActive) cont.resume(AnnouncementResult.Failed(error.errorCodeName))
                            }
                        },
                    )
                    player.setMediaItem(MediaItem.fromUri(url))
                    player.prepare()
                    player.play()
                }
            } finally {
                current = null
                player.release()
            }
        }

        override fun stop() {
            current?.stop()
        }

        private companion object {
            const val PLAY_TIMEOUT_MS = 20_000L
        }
    }
