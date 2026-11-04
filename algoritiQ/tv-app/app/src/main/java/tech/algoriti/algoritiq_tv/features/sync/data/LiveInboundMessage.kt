/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.data

import kotlinx.serialization.json.JsonObject

sealed interface LiveInboundMessage {
    val eventSequence: Long

    data class Hello(
        override val eventSequence: Long,
    ) : LiveInboundMessage

    data class Snapshot(
        override val eventSequence: Long,
        val payload: JsonObject?,
    ) : LiveInboundMessage

    data class Event(
        override val eventSequence: Long,
        val name: String,
        val payload: JsonObject?,
    ) : LiveInboundMessage

    data class Ping(
        override val eventSequence: Long,
    ) : LiveInboundMessage
}
