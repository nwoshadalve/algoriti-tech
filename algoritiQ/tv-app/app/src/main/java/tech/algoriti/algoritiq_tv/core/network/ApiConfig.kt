/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

/** Where the TV finds the clinic tablet: [defaultHost], always the `algoritiq.local` name. */
data class ApiConfig(
    val defaultHost: String,
) {
    companion object {
        /** `wss://host:8443/api/v1/ws/tv` for a base address like `https://host:8443`. */
        fun liveWebSocketUrl(baseHost: String): String {
            val wsHost =
                baseHost
                    .removeSuffix("/")
                    .replace("https://", "wss://")
                    .replace("http://", "ws://")
            return "$wsHost/api/v1/ws/tv"
        }

        /** An address from the tablet (`/api/v1/...`) made absolute against [baseHost]. */
        fun absoluteUrl(
            baseHost: String,
            pathOrUrl: String,
        ): String =
            if (pathOrUrl.startsWith("http://") || pathOrUrl.startsWith("https://")) {
                pathOrUrl
            } else {
                "${baseHost.removeSuffix("/")}${if (pathOrUrl.startsWith("/")) pathOrUrl else "/$pathOrUrl"}"
            }
    }
}
