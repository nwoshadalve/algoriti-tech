/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.shell.application

import javax.inject.Inject
import javax.inject.Singleton
import kotlin.random.Random
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import tech.algoriti.algoritiq_tv.core.network.ApiConfig
import tech.algoriti.algoritiq_tv.features.sync.domain.LiveSessionRepository

/**
 * Keeps this TV linked to the clinic tablet for as long as the app process lives. It reconnects
 * with growing, jittered waits whenever the connection drops. It lives in the application, not in
 * a screen, so the link survives the screen being rebuilt.
 */
@Singleton
class TvConnection
    @Inject
    constructor(
        private val config: ApiConfig,
        private val live: LiveSessionRepository,
    ) {
        private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        private var started = false

        /** Starts linking (once). Call from [android.app.Application.onCreate]. */
        fun start() {
            if (started) return
            started = true
            scope.launch { keepConnected() }
        }

        private suspend fun keepConnected() {
            var wait = MIN_WAIT_MS
            while (true) {
                val began = System.currentTimeMillis()
                live.runSession(config.defaultHost)
                // A link that held for a while was healthy: start the waits again from short.
                wait = if (System.currentTimeMillis() - began > STABLE_MS) MIN_WAIT_MS else minOf(wait * 2, MAX_WAIT_MS)
                delay(wait + Random.nextLong(JITTER_MS))
            }
        }

        private companion object {
            const val MIN_WAIT_MS = 2_000L
            const val MAX_WAIT_MS = 30_000L
            const val STABLE_MS = 20_000L
            const val JITTER_MS = 1_000L
        }
    }
