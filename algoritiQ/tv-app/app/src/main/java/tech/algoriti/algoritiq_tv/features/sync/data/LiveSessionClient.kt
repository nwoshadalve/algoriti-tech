/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.data

interface LiveSessionClient {
    /** Blocks until the WebSocket to [baseHost] closes or fails. */
    suspend fun openSession(
        baseHost: String,
        onMessage: (LiveInboundMessage) -> Unit,
    )

    /** Sends a text frame on the open session; false when there is none. */
    fun send(text: String): Boolean

    fun closeSession()
}
