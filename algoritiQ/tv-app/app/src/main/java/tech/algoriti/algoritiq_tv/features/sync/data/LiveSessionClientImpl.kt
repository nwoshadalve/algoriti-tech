/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.data

import java.util.concurrent.atomic.AtomicReference
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume
import kotlinx.coroutines.suspendCancellableCoroutine
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import tech.algoriti.algoritiq_tv.core.network.ApiConfig
import tech.algoriti.algoritiq_tv.core.network.ClinicTls
import timber.log.Timber

/**
 * The live channel to the tablet: a WebSocket over TLS with the tablet's self-signed certificate.
 * The tablet sends the board and commands on it; the TV answers on it.
 */
@Singleton
class LiveSessionClientImpl
    @Inject
    constructor(
        private val okHttpClient: OkHttpClient,
    ) : LiveSessionClient {
        private val activeSocket = AtomicReference<WebSocket?>(null)

        override suspend fun openSession(
            baseHost: String,
            onMessage: (LiveInboundMessage) -> Unit,
        ) {
            Timber.i("live_ws_connect")
            val client = ClinicTls.selfSigned(okHttpClient)
            val request =
                Request
                    .Builder()
                    .url(ApiConfig.liveWebSocketUrl(baseHost))
                    .build()
            suspendCancellableCoroutine { cont ->
                val ws =
                    client.newWebSocket(
                        request,
                        object : WebSocketListener() {
                            override fun onOpen(
                                webSocket: WebSocket,
                                response: Response,
                            ) {
                                activeSocket.set(webSocket)
                            }

                            override fun onMessage(
                                webSocket: WebSocket,
                                text: String,
                            ) {
                                Timber.d("live_ws_frame %s", text.take(60))
                                val frame = parseLiveFrame(text) ?: return
                                when (frame) {
                                    is LiveInboundMessage.Ping -> webSocket.send("""{"type":"pong"}""")
                                    else -> onMessage(frame)
                                }
                            }

                            override fun onFailure(
                                webSocket: WebSocket,
                                t: Throwable,
                                response: Response?,
                            ) {
                                Timber.w(t, "live_ws_failure")
                                activeSocket.compareAndSet(webSocket, null)
                                if (cont.isActive) cont.resume(Unit)
                            }

                            override fun onClosed(
                                webSocket: WebSocket,
                                code: Int,
                                reason: String,
                            ) {
                                Timber.i("live_ws_closed code=%d", code)
                                activeSocket.compareAndSet(webSocket, null)
                                if (cont.isActive) cont.resume(Unit)
                            }
                        },
                    )
                cont.invokeOnCancellation {
                    ws.close(1000, "cancelled")
                    activeSocket.compareAndSet(ws, null)
                }
            }
        }

        override fun send(text: String): Boolean = activeSocket.get()?.send(text) ?: false

        override fun closeSession() {
            activeSocket.getAndSet(null)?.close(1000, "client_close")
        }
    }
