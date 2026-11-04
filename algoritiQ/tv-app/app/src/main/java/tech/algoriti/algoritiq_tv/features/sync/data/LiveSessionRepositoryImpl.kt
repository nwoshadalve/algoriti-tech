/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.data

import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonPrimitive
import tech.algoriti.algoritiq_tv.core.network.ApiConfig
import tech.algoriti.algoritiq_tv.features.announcement.domain.AnnouncementPlayer
import tech.algoriti.algoritiq_tv.features.announcement.domain.AnnouncementResult
import tech.algoriti.algoritiq_tv.features.display.domain.ChamberDisplays
import tech.algoriti.algoritiq_tv.features.display.domain.TvDisplayMapper
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState
import tech.algoriti.algoritiq_tv.features.sync.domain.ConnectionState
import tech.algoriti.algoritiq_tv.features.sync.domain.EventSequenceTracker
import tech.algoriti.algoritiq_tv.features.sync.domain.LiveSessionRepository
import tech.algoriti.algoritiq_tv.features.sync.domain.LiveSessionStatus
import tech.algoriti.algoritiq_tv.features.sync.domain.SoundProgress
import tech.algoriti.algoritiq_tv.features.sync.domain.TestScreenState
import tech.algoriti.algoritiq_tv.features.sync.domain.TvTestCommand
import tech.algoriti.algoritiq_tv.features.sync.domain.TvTestReply
import timber.log.Timber

@Singleton
class LiveSessionRepositoryImpl
    @Inject
    constructor(
        private val client: LiveSessionClient,
        private val announcementPlayer: AnnouncementPlayer,
    ) : LiveSessionRepository {
        private val mutex = Mutex()
        private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        private val sequenceTracker = EventSequenceTracker()
        private val chambers = ChamberDisplays()
        private var testJob: Job? = null
        private val _status = MutableStateFlow(LiveSessionStatus())
        override val status: StateFlow<LiveSessionStatus> = _status.asStateFlow()

        private val _display = MutableStateFlow(DisplayBoardState(connected = false))
        override val display: StateFlow<DisplayBoardState> = _display.asStateFlow()

        private val _reachedMain = MutableStateFlow(false)
        override val reachedMain: StateFlow<Boolean> = _reachedMain.asStateFlow()

        private val _testScreen = MutableStateFlow<TestScreenState?>(null)
        override val testScreen: StateFlow<TestScreenState?> = _testScreen.asStateFlow()

        private val timeFormat = SimpleDateFormat("HH:mm", Locale("bn", "BD"))

        override suspend fun runSession(baseHost: String) =
            mutex.withLock {
                _status.value = _status.value.copy(connectionState = ConnectionState.Connecting)
                try {
                    client.openSession(baseHost) { frame ->
                        // One bad frame must not drop the connection.
                        runCatching { onFrame(frame, baseHost) }
                            .onFailure { Timber.w(it, "live_frame_error") }
                    }
                } finally {
                    client.closeSession()
                    _status.value = _status.value.copy(connectionState = ConnectionState.Disconnected)
                    _display.value = _display.value.copy(connected = false, lastUpdateLabel = formatNow())
                }
            }

        private fun onFrame(
            frame: LiveInboundMessage,
            baseHost: String,
        ) {
            when (frame) {
                is LiveInboundMessage.Hello -> {
                    sequenceTracker.reset(frame.eventSequence)
                    markConnected(frame.eventSequence)
                }
                is LiveInboundMessage.Snapshot -> {
                    sequenceTracker.reset(frame.eventSequence)
                    applyDisplayPayload(frame.payload, connected = true)
                    _reachedMain.value = true
                    markConnected(frame.eventSequence)
                }
                is LiveInboundMessage.Event -> onEvent(frame, baseHost)
                is LiveInboundMessage.Ping -> Unit
            }
        }

        private fun onEvent(
            frame: LiveInboundMessage.Event,
            baseHost: String,
        ) {
            if (sequenceTracker.hasGap(frame.eventSequence)) {
                Timber.w("live_sequence_gap at=%d", frame.eventSequence)
                sequenceTracker.reset()
                return
            }
            if (!sequenceTracker.accept(frame.eventSequence)) return
            when (frame.name) {
                TvTestCommand.EVENT_NAME -> {
                    testJob?.cancel()
                    testJob = scope.launch { runTest(frame.payload, baseHost) }
                }
                "token.called" -> {
                    scope.launch { maybePlayAnnouncement(frame.payload, baseHost) }
                    applyDisplayPayload(frame.payload, connected = true)
                }
                else -> applyDisplayPayload(frame.payload, connected = true)
            }
            markConnected(frame.eventSequence)
        }

        /**
         * Puts the test screen up, plays the test sound when asked, and reports what actually
         * happened. The real board is not touched.
         */
        private suspend fun runTest(
            payload: JsonObject?,
            baseHost: String,
        ) {
            val command = TvTestCommand.from(payload) ?: return
            val soundPath = command.soundPath
            _testScreen.value = TestScreenState(if (soundPath == null) SoundProgress.NotRequested else SoundProgress.Playing)
            var audio = TvTestReply.AUDIO_SKIPPED
            var error: String? = null
            if (soundPath != null) {
                val url = ApiConfig.absoluteUrl(baseHost, soundPath)
                when (val result = announcementPlayer.play(url, command.testId)) {
                    AnnouncementResult.Played, AnnouncementResult.Skipped -> audio = TvTestReply.AUDIO_PLAYED
                    is AnnouncementResult.Failed -> {
                        audio = TvTestReply.AUDIO_FAILED
                        error = result.reason
                    }
                }
                _testScreen.value =
                    TestScreenState(if (audio == TvTestReply.AUDIO_PLAYED) SoundProgress.Played else SoundProgress.Failed)
            }
            client.send(TvTestReply.json(command.testId, audio, error))
            delay(TEST_SCREEN_MS)
            _testScreen.value = null
        }

        override fun reset() {
            testJob?.cancel()
            _testScreen.value = null
            _reachedMain.value = false
            _display.value = DisplayBoardState(connected = false)
        }

        override fun stopSession() {
            client.closeSession()
        }

        private fun markConnected(sequence: Long) {
            _status.value =
                _status.value.copy(
                    connectionState = ConnectionState.Connected,
                    lastEventSequence = sequence,
                    lastUpdateEpochMs = System.currentTimeMillis(),
                )
        }

        private fun applyDisplayPayload(
            payload: JsonObject?,
            connected: Boolean,
        ) {
            val arrived = displaysFromPayload(payload)
            if (arrived.isEmpty()) return
            arrived.forEach(chambers::update)
            val displayJson = chambers.current() ?: return
            _display.value =
                TvDisplayMapper.fromDisplayJson(
                    display = displayJson,
                    connected = connected,
                    lastUpdateLabel = formatNow(),
                )
        }

        private fun formatNow(): String = timeFormat.format(Date())

        private suspend fun maybePlayAnnouncement(
            payload: JsonObject?,
            baseHost: String,
        ) {
            if (payload == null) return
            val path = payload["announcementUrl"]?.jsonPrimitive?.contentOrNull ?: return
            val callId = payload["callId"]?.jsonPrimitive?.contentOrNull ?: return
            val result = announcementPlayer.play(ApiConfig.absoluteUrl(baseHost, path), callId)
            if (result is AnnouncementResult.Failed) Timber.w("announcement_failed reason=%s", result.reason)
        }

        private companion object {
            /** How long the test screen stays up after the TV has answered. */
            const val TEST_SCREEN_MS = 5_000L
        }
    }
