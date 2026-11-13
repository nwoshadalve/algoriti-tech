/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale
import java.util.UUID

/**
 * The tablet's Bengali voice, for the spoken call on the waiting-room TV.
 *
 * Runs the Android `TextToSpeech` engine and hands back the finished clip as WAV
 * bytes (the TV downloads it from the tablet; it never speaks itself). It prefers an
 * installed Bengali voice that needs no internet, then the best one available.
 * Flutter side: `AndroidSpeechSynthesizer`. One call: `synthesize(text)`.
 */
class SpeechChannel(private val context: Context) : MethodChannel.MethodCallHandler {
    private val main = Handler(Looper.getMainLooper())
    private var engine: TextToSpeech? = null
    private var ready = false
    private var failed = false
    private val waitingForEngine = ArrayList<() -> Unit>()
    private val jobs = HashMap<String, Job>()

    private class Job(val file: File, val result: MethodChannel.Result, val timeout: Runnable)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "synthesize" -> {
                val text = call.argument<String>("text")
                if (text.isNullOrBlank()) {
                    result.error("EMPTY", "Nothing to say", null)
                    return
                }
                whenReady(result) { speak(text, result) }
            }
            else -> result.notImplemented()
        }
    }

    private fun whenReady(result: MethodChannel.Result, then: () -> Unit) {
        if (failed) return result.error("NO_ENGINE", "No text-to-speech engine", null)
        if (ready) return then()
        waitingForEngine.add(then)
        if (engine != null) return
        engine = TextToSpeech(context.applicationContext) { status ->
            main.post {
                if (status == TextToSpeech.SUCCESS && prepareVoice()) {
                    ready = true
                    waitingForEngine.forEach { it() }
                } else {
                    failed = true
                    engine?.shutdown()
                    engine = null
                    // Let a later call try again (the voice may have been installed meanwhile).
                    main.postDelayed({ failed = false }, RETRY_AFTER_MS)
                    waitingForEngine.forEach { it() }
                }
                waitingForEngine.clear()
            }
        }
    }

    /** Chooses the Bengali voice. False when the tablet has none installed. */
    private fun prepareVoice(): Boolean {
        val tts = engine ?: return false
        val locale = listOf(Locale("bn", "BD"), Locale("bn", "IN"), Locale("bn"))
            .firstOrNull {
                val r = tts.setLanguage(it)
                r != TextToSpeech.LANG_MISSING_DATA && r != TextToSpeech.LANG_NOT_SUPPORTED
            } ?: return false
        val best = runCatching { tts.voices }.getOrNull().orEmpty()
            .filter { it.locale.language == "bn" && !isMissing(it) }
            .sortedWith(compareBy<Voice> { it.isNetworkConnectionRequired }.thenByDescending { it.quality })
            .firstOrNull()
        if (best != null) tts.setVoice(best)
        tts.setSpeechRate(0.92f)
        tts.setOnUtteranceProgressListener(listener)
        Log.i(TAG, "voice=${best?.name} locale=$locale offline=${best?.isNetworkConnectionRequired == false}")
        return true
    }

    private fun isMissing(voice: Voice) =
        voice.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)

    private fun speak(text: String, result: MethodChannel.Result) {
        val tts = engine
        if (!ready || tts == null) return result.error("NO_VOICE", "No Bengali voice installed", null)
        val id = UUID.randomUUID().toString()
        val file = File(context.cacheDir, "speech-$id.wav")
        val timeout = Runnable { finish(id) { it.result.error("TIMEOUT", "The voice took too long", null) } }
        jobs[id] = Job(file, result, timeout)
        main.postDelayed(timeout, SPEAK_TIMEOUT_MS)
        val started = tts.synthesizeToFile(text, Bundle(), file, id)
        if (started != TextToSpeech.SUCCESS) {
            finish(id) { it.result.error("FAILED", "The voice could not start", null) }
        }
    }

    private val listener = object : UtteranceProgressListener() {
        override fun onStart(utteranceId: String?) = Unit

        override fun onDone(utteranceId: String?) {
            val id = utteranceId ?: return
            main.post {
                finish(id) { job ->
                    val bytes = runCatching { job.file.readBytes() }.getOrNull()
                    if (bytes == null || bytes.isEmpty()) {
                        job.result.error("EMPTY_CLIP", "The voice made no sound", null)
                    } else {
                        job.result.success(bytes)
                    }
                }
            }
        }

        @Deprecated("Deprecated in Java")
        override fun onError(utteranceId: String?) {
            val id = utteranceId ?: return
            main.post { finish(id) { it.result.error("FAILED", "The voice failed", null) } }
        }
    }

    /** Ends a job once, however it ended: stops its timer, removes its file, answers the caller. */
    private fun finish(id: String, answer: (Job) -> Unit) {
        val job = jobs.remove(id) ?: return
        main.removeCallbacks(job.timeout)
        try {
            answer(job)
        } finally {
            job.file.delete()
        }
    }

    companion object {
        const val NAME = "tech.algoriti.algoritiq/speech"
        private const val TAG = "AlgoritiSpeech"
        private const val SPEAK_TIMEOUT_MS = 12_000L
        private const val RETRY_AFTER_MS = 60_000L

        fun register(engine: FlutterEngine, context: Context) {
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(SpeechChannel(context))
        }
    }
}
