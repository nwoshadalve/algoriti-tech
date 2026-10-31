/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * The one Flutter engine for the whole app process.
 *
 * It outlives the screen: the tablet's local API (HTTPS, queue) runs inside
 * it, so it must keep running when the Activity is closed, the screen is
 * locked, or the tablet has just restarted (then [KeepAliveService] creates it
 * with no screen at all). The Activity attaches to it when it opens.
 */
object EngineHolder {
    private const val ENGINE_ID = "algoritiq_main"

    /** The visible Activity, if any. Needed for permission dialogs and settings. */
    @Volatile
    var activity: Activity? = null

    /** Creates and starts the engine once; later calls return the same one. */
    @Synchronized
    fun ensure(context: Context): FlutterEngine {
        val cache = FlutterEngineCache.getInstance()
        cache.get(ENGINE_ID)?.let { return it }

        val app = context.applicationContext
        // Data from an older version must be in place before Dart reads it.
        check(DeviceStorage.isReady(app)) { "App data not moved yet" }
        // Plugins are registered by the engine itself.
        val engine = FlutterEngine(app)
        DeviceIdChannel.register(engine, app)
        SplashChannel.register(engine) { SplashHold.release() }
        KeepAliveChannel.register(engine, app)
        SystemHealthChannel.register(engine, app)
        PrinterChannel.register(engine, app)
        BackupChannel.register(engine, app)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault(),
        )
        cache.put(ENGINE_ID, engine)
        return engine
    }
}

/**
 * Remembers that the first real screen has been drawn, so reopening the app
 * later does not wait for the launch screen to be released again.
 */
object SplashHold {
    @Volatile
    var ready = false
        private set

    @Volatile
    var onRelease: (() -> Unit)? = null

    fun release() {
        ready = true
        onRelease?.invoke()
    }
}
