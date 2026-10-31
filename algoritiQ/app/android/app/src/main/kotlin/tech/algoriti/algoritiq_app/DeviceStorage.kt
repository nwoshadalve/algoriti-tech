/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.os.UserManager
import android.util.Log
import androidx.annotation.RequiresApi
import java.io.File

/**
 * Moves data written by earlier versions from credential-protected storage
 * (readable only after the first unlock) to device-protected storage (see
 * [AlgoritiqApplication]).
 *
 * The move needs the tablet to have been unlocked once since power-on. Until
 * it has run, the engine must not start: it would see an empty database.
 */
object DeviceStorage {
    private const val TAG = "DeviceStorage"
    private const val MARKER = "storage_moved_to_device"

    /** Directories under the data folder that hold app data. */
    private val MOVED = listOf("app_flutter", "shared_prefs", "files")

    /** The original (credential-protected) context, set by the Application. */
    @Volatile
    var credentialContext: Context? = null

    /** True when the engine may start: the data is where it will be read. */
    fun isReady(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return true
        return marker(context).exists() || (isUnlocked(context) && moveIfNeeded(context))
    }

    @RequiresApi(Build.VERSION_CODES.N)
    @Synchronized
    private fun moveIfNeeded(context: Context): Boolean {
        val target = marker(context)
        if (target.exists()) return true
        val source = credentialContext?.dataDir
        val destination = context.applicationContext.dataDir
        if (source == null || source == destination) return markDone(target)
        return try {
            for (name in MOVED) {
                val from = File(source, name)
                if (from.exists()) from.copyRecursively(File(destination, name), overwrite = true)
            }
            repointPhotos(destination, source.path, destination.path)
            markDone(target)
            for (name in MOVED) File(source, name).deleteRecursively()
            true
        } catch (e: Exception) {
            // Left in place; tried again on the next start.
            Log.e(TAG, "Moving app data failed", e)
            false
        }
    }

    /** Doctor photos are saved with their full path, which has just changed. */
    private fun repointPhotos(dataDir: File, oldRoot: String, newRoot: String) {
        val database = File(dataDir, "app_flutter/algoritiq.sqlite")
        if (!database.exists()) return
        SQLiteDatabase.openDatabase(database.path, null, SQLiteDatabase.OPEN_READWRITE).use {
            try {
                it.execSQL(
                    "UPDATE doctors SET photo_path = ? || substr(photo_path, ?) " +
                        "WHERE photo_path LIKE ? || '%'",
                    arrayOf<Any>(newRoot, oldRoot.length + 1, oldRoot),
                )
            } catch (e: Exception) {
                // An older database without the doctors table: nothing to fix.
                Log.w(TAG, "No doctor photos to move", e)
            }
        }
    }

    private fun markDone(marker: File): Boolean {
        marker.parentFile?.mkdirs()
        marker.createNewFile()
        return true
    }

    private fun marker(context: Context) = File(context.applicationContext.noBackupFilesDir, MARKER)

    @RequiresApi(Build.VERSION_CODES.N)
    private fun isUnlocked(context: Context): Boolean =
        context.getSystemService(UserManager::class.java).isUserUnlocked
}
