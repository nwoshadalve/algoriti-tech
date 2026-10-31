/*
 * Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
 * All rights reserved.
 *
 * Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
 * or distribution is prohibited.
 */
package tech.algoriti.algoritiq_app

import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

/**
 * Clinic data backup and restore: the same folders as manual `adb` backup
 * (`app_flutter`, `shared_prefs`, `files`). Flutter: [BackupGateway].
 */
class BackupChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "create" -> {
                val kind = call.argument<String>("kind") ?: "manual"
                val secrets = call.argument<Map<String, String>>("secrets") ?: emptyMap()
                runCatching { create(kind, secrets) }
                    .onSuccess { result.success(it) }
                    .onFailure { result.error("BACKUP_FAILED", it.message, null) }
            }
            "list" -> runCatching { list() }
                .onSuccess { result.success(it) }
                .onFailure { result.error("LIST_FAILED", it.message, null) }
            "delete" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID", "Missing backup id.", null)
                    return
                }
                runCatching { delete(id) }
                    .onSuccess { result.success(null) }
                    .onFailure { result.error("DELETE_FAILED", it.message, null) }
            }
            "restore" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID", "Missing backup id.", null)
                    return
                }
                runCatching { restore(id) }
                    .onSuccess { result.success(it) }
                    .onFailure { result.error("RESTORE_FAILED", it.message, null) }
            }
            "archivePath" -> {
                val id = call.argument<String>("id")
                if (id.isNullOrBlank()) {
                    result.error("INVALID", "Missing backup id.", null)
                    return
                }
                val file = archiveFile(id)
                if (!file.exists()) {
                    result.error("NOT_FOUND", "Backup not found.", null)
                    return
                }
                result.success(file.absolutePath)
            }
            "importArchive" -> {
                val path = call.argument<String>("path")
                if (path.isNullOrBlank()) {
                    result.error("INVALID", "Missing archive path.", null)
                    return
                }
                runCatching { importArchive(File(path)) }
                    .onSuccess { result.success(it) }
                    .onFailure { result.error("IMPORT_FAILED", it.message, null) }
            }
            "restart" -> {
                val activity = EngineHolder.activity
                if (activity == null) {
                    result.error("NO_ACTIVITY", "App not in foreground.", null)
                    return
                }
                val launch =
                    activity.packageManager.getLaunchIntentForPackage(activity.packageName)
                if (launch == null) {
                    result.error("RESTART_FAILED", "Could not restart.", null)
                    return
                }
                launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                activity.startActivity(launch)
                Runtime.getRuntime().exit(0)
            }
            else -> result.notImplemented()
        }
    }

    private fun backupsRoot(): File =
        File(context.noBackupFilesDir, "clinic_backups").also { it.mkdirs() }

    private fun backupDir(id: String): File = File(backupsRoot(), id)

    private fun archiveFile(id: String): File = File(backupDir(id), ARCHIVE_NAME)

    private fun metaFile(id: String): File = File(backupDir(id), META_NAME)

    private fun create(kind: String, secrets: Map<String, String>): Map<String, Any?> {
        checkpointDatabase()
        val id = newId()
        val dir = backupDir(id)
        dir.mkdirs()
        val archive = archiveFile(id)
        zipClinicData(archive, secrets)
        val createdAt = System.currentTimeMillis()
        val sizeBytes = archive.length()
        writeMeta(
            id,
            JSONObject()
                .put("id", id)
                .put("createdAt", createdAt)
                .put("sizeBytes", sizeBytes)
                .put("kind", kind),
        )
        return mapOf(
            "id" to id,
            "createdAt" to createdAt,
            "sizeBytes" to sizeBytes,
            "kind" to kind,
        )
    }

    private fun list(): List<Map<String, Any?>> {
        val root = backupsRoot()
        return root.listFiles()?.mapNotNull { child ->
            if (!child.isDirectory) return@mapNotNull null
            readMeta(child.name)?.toMap()
        }?.sortedByDescending { (it["createdAt"] as? Number)?.toLong() ?: 0L } ?: emptyList()
    }

    private fun delete(id: String) {
        val dir = backupDir(id)
        if (!dir.exists()) throw IllegalArgumentException("Backup not found.")
        dir.deleteRecursively()
    }

    /** Returns the secrets stored in the archive (empty for older archives). */
    private fun restore(id: String): Map<String, String> {
        val archive = archiveFile(id)
        if (!archive.exists()) throw IllegalArgumentException("Backup not found.")
        checkpointDatabase()
        val dataDir = context.applicationContext.dataDir
        for (name in DATA_DIRS) {
            File(dataDir, name).listFiles()?.forEach { if (!isKept("$name/${it.name}")) it.deleteRecursively() }
        }
        unzipClinicData(archive, dataDir)
        File(context.applicationContext.noBackupFilesDir, DeviceStorageMarker).createNewFile()
        KeepAliveService.start(context.applicationContext)
        return readSecrets(archive)
    }

    private fun readSecrets(archive: File): Map<String, String> {
        ZipInputStream(BufferedInputStream(FileInputStream(archive))).use { zip ->
            var entry = zip.nextEntry
            while (entry != null) {
                if (entry.name == SECRETS_ENTRY) {
                    val json = JSONObject(zip.readBytes().toString(Charsets.UTF_8))
                    return json.keys().asSequence().associateWith { json.getString(it) }
                }
                zip.closeEntry()
                entry = zip.nextEntry
            }
        }
        return emptyMap()
    }

    /** Copies a zip downloaded off the tablet into the backup list (for restore on a new device). */
    private fun importArchive(sourceZip: File): Map<String, Any?> {
        if (!sourceZip.isFile) throw IllegalArgumentException("Backup file missing.")
        if (!looksLikeClinicBackup(sourceZip)) {
            throw IllegalArgumentException("Not an AlgoritiQ clinic backup zip.")
        }
        val id = newId()
        val dir = backupDir(id)
        dir.mkdirs()
        sourceZip.copyTo(archiveFile(id), overwrite = true)
        val createdAt = System.currentTimeMillis()
        val sizeBytes = archiveFile(id).length()
        writeMeta(
            id,
            JSONObject()
                .put("id", id)
                .put("createdAt", createdAt)
                .put("sizeBytes", sizeBytes)
                .put("kind", "manual"),
        )
        return mapOf(
            "id" to id,
            "createdAt" to createdAt,
            "sizeBytes" to sizeBytes,
            "kind" to "manual",
        )
    }

    private fun looksLikeClinicBackup(archive: File): Boolean {
        ZipInputStream(BufferedInputStream(FileInputStream(archive))).use { zip ->
            var entry = zip.nextEntry
            while (entry != null) {
                val name = entry.name.trimStart('/')
                if (DATA_DIRS.any { name == it || name.startsWith("$it/") }) return true
                zip.closeEntry()
                entry = zip.nextEntry
            }
        }
        return false
    }

    private fun checkpointDatabase() {
        val db = File(context.applicationContext.dataDir, "app_flutter/algoritiq.sqlite")
        if (!db.exists()) return
        SQLiteDatabase.openDatabase(db.path, null, SQLiteDatabase.OPEN_READWRITE).use { database ->
            database.rawQuery("PRAGMA wal_checkpoint(FULL)", null).close()
        }
    }

    private fun zipClinicData(out: File, secrets: Map<String, String>) {
        val dataDir = context.applicationContext.dataDir
        ZipOutputStream(BufferedOutputStream(FileOutputStream(out))).use { zip ->
            for (name in DATA_DIRS) {
                val root = File(dataDir, name)
                if (root.exists()) addTree(zip, root, name)
            }
            if (secrets.isNotEmpty()) {
                zip.putNextEntry(ZipEntry(SECRETS_ENTRY))
                zip.write(JSONObject(secrets).toString().toByteArray(Charsets.UTF_8))
                zip.closeEntry()
            }
        }
    }

    private fun unzipClinicData(archive: File, dataDir: File) {
        ZipInputStream(BufferedInputStream(FileInputStream(archive))).use { zip ->
            var entry = zip.nextEntry
            while (entry != null) {
                val target = File(dataDir, entry.name)
                if (isKept(entry.name.trimStart('/')) || entry.name == SECRETS_ENTRY) {
                    // Never replace what belongs to this install (see isKept); secrets are read apart.
                } else if (entry.isDirectory) {
                    target.mkdirs()
                } else {
                    target.parentFile?.mkdirs()
                    FileOutputStream(target).use { out -> zip.copyTo(out) }
                }
                zip.closeEntry()
                entry = zip.nextEntry
            }
        }
    }

    private fun addTree(zip: ZipOutputStream, file: File, path: String) {
        if (isKept(path)) return
        if (file.isDirectory) {
            val children = file.listFiles() ?: return
            if (children.isEmpty()) {
                zip.putNextEntry(ZipEntry("$path/"))
                zip.closeEntry()
            } else {
                for (child in children) addTree(zip, child, "$path/${child.name}")
            }
        } else {
            zip.putNextEntry(ZipEntry(path))
            FileInputStream(file).use { input -> input.copyTo(zip) }
            zip.closeEntry()
        }
    }

    /**
     * What belongs to this install, not to the clinic, so it is neither saved nor restored:
     * the app's own code that debug builds unpack into `app_flutter` (an old copy would run old
     * code), and the secure-storage files, whose key lives in this tablet's Keystore and cannot be
     * opened anywhere else. The secrets themselves travel apart, in [SECRETS_ENTRY].
     */
    private fun isKept(path: String): Boolean =
        path.startsWith("app_flutter/flutter_assets") ||
            path.startsWith("app_flutter/res_timestamp") ||
            path.startsWith("shared_prefs/FlutterSecure")

    private fun newId(): String =
        SimpleDateFormat("yyyyMMdd-HHmmss", Locale.US).format(Date())

    private fun writeMeta(id: String, json: JSONObject) {
        metaFile(id).writeText(json.toString())
    }

    private fun readMeta(id: String): JSONObject? {
        val file = metaFile(id)
        if (!file.exists()) return null
        return try {
            JSONObject(file.readText())
        } catch (e: Exception) {
            Log.w(TAG, "Skipping corrupt backup meta $id", e)
            null
        }
    }

    private fun JSONObject.toMap(): Map<String, Any?> = mapOf(
        "id" to getString("id"),
        "createdAt" to getLong("createdAt"),
        "sizeBytes" to getLong("sizeBytes"),
        "kind" to getString("kind"),
    )

    companion object {
        const val NAME = "tech.algoriti.algoritiq/backup"
        private const val TAG = "BackupChannel"
        private const val ARCHIVE_NAME = "clinic-backup.zip"
        private const val META_NAME = "meta.json"
        private const val SECRETS_ENTRY = "secrets.json"
        private const val DeviceStorageMarker = "storage_moved_to_device"
        private val DATA_DIRS = listOf("app_flutter", "shared_prefs", "files")

        fun register(engine: FlutterEngine, context: Context) {
            MethodChannel(engine.dartExecutor.binaryMessenger, NAME)
                .setMethodCallHandler(BackupChannel(context.applicationContext))
        }
    }
}
