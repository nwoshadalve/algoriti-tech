/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.domain

import kotlinx.coroutines.flow.StateFlow
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState

enum class ConnectionState {
    Disconnected,
    Connecting,
    Connected,
}

data class LiveSessionStatus(
    val connectionState: ConnectionState = ConnectionState.Disconnected,
    val lastEventSequence: Long = 0L,
    val lastUpdateEpochMs: Long? = null,
)

/** How the sound part of a test screen stands. */
enum class SoundProgress {
    NotRequested,
    Playing,
    Played,
    Failed,
}

/** The test screen staff asked for from the tablet. Shown over the board for a few seconds. */
data class TestScreenState(
    val sound: SoundProgress,
)

interface LiveSessionRepository {
    val status: StateFlow<LiveSessionStatus>

    val display: StateFlow<DisplayBoardState>

    /** True after the first `snapshot` frame in this process. */
    val reachedMain: StateFlow<Boolean>

    /** Non-null while a test screen is up. */
    val testScreen: StateFlow<TestScreenState?>

    /** Runs one WebSocket session until it ends, and says how. */
    suspend fun runSession(baseHost: String)

    /** Forgets everything shown. */
    fun reset()

    fun stopSession()
}
