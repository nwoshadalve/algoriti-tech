/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.announcement.domain

sealed interface AnnouncementResult {
    /** The clip played to the end. */
    data object Played : AnnouncementResult

    /** The same announcement had already been played (a repeat after a reconnect). */
    data object Skipped : AnnouncementResult

    /** The clip could not be fetched or played; [reason] is a short safe code. */
    data class Failed(
        val reason: String,
    ) : AnnouncementResult
}

interface AnnouncementPlayer {
    /**
     * Fetches the clip at [url] from the tablet over the same secure connection as everything
     * else, plays it and says how that went. Plays one clip at a time.
     */
    suspend fun play(
        url: String,
        announcementId: String,
    ): AnnouncementResult

    fun stop()
}
