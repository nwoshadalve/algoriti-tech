/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.domain

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.put

/** A `tv.test` command: put a test screen up and, when [soundPath] is set, play that clip. */
data class TvTestCommand(
    val testId: String,
    val soundPath: String?,
) {
    companion object {
        const val EVENT_NAME = "tv.test"

        fun from(payload: JsonObject?): TvTestCommand? {
            val id = payload?.get("testId")?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() } ?: return null
            val sound = payload["announcementUrl"]?.jsonPrimitive?.contentOrNull?.takeIf { it.isNotBlank() }
            return TvTestCommand(id, sound)
        }
    }
}

/** What the TV reports back about a test: it says what it did, not what it was asked. */
object TvTestReply {
    const val AUDIO_PLAYED = "played"
    const val AUDIO_FAILED = "failed"
    const val AUDIO_SKIPPED = "skipped"

    fun json(
        testId: String,
        audio: String,
        error: String? = null,
    ): String =
        buildJsonObject {
            put("type", "ack")
            put("name", TvTestCommand.EVENT_NAME)
            put("testId", testId)
            put("display", "shown")
            put("audio", audio)
            if (error != null) put("error", error)
        }.toString()
}
