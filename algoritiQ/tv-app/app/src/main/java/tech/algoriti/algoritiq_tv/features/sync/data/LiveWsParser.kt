/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.data

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.longOrNull

private val json = Json { ignoreUnknownKeys = true }

internal fun parseLiveFrame(raw: String): LiveInboundMessage? {
    val root =
        runCatching { json.parseToJsonElement(raw).jsonObject }.getOrNull() ?: return null
    return when (root.string("type")) {
        "hello" ->
            LiveInboundMessage.Hello(
                eventSequence = root.long("eventSequence") ?: 0L,
            )
        "snapshot" ->
            LiveInboundMessage.Snapshot(
                eventSequence = root.long("eventSequence") ?: 0L,
                payload = root["payload"]?.jsonObject,
            )
        "event" ->
            LiveInboundMessage.Event(
                eventSequence = root.long("eventSequence") ?: 0L,
                name = root.string("name").orEmpty(),
                payload = root["payload"]?.jsonObject,
            )
        "ping" ->
            LiveInboundMessage.Ping(
                eventSequence = root.long("eventSequence") ?: 0L,
            )
        else -> null
    }
}

private fun JsonObject.string(key: String): String? = this[key]?.jsonPrimitive?.contentOrNull

private fun JsonObject.long(key: String): Long? = this[key]?.jsonPrimitive?.longOrNull

internal fun displaysFromPayload(payload: JsonObject?): List<JsonObject> {
    if (payload == null) return emptyList()
    (payload["display"] as? JsonObject)?.let { return listOf(it) }
    return (payload["displays"] as? JsonArray).orEmpty().mapNotNull { it as? JsonObject }
}
