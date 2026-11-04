/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import java.security.SecureRandom
import java.security.cert.X509Certificate
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager
import okhttp3.OkHttpClient

/**
 * TLS to the clinic tablet. The tablet makes its own certificate, so no authority signs it and the
 * usual check cannot pass. This TV talks to one address only ([CLINIC_HOST]); the client built here
 * accepts the tablet's self-signed certificate for that name and refuses any other name.
 */
object ClinicTls {
    /** The name every TV uses to reach the tablet. The tablet answers to it on the local network. */
    const val CLINIC_HOST = "algoritiq.local"

    fun selfSigned(base: OkHttpClient): OkHttpClient {
        val trust =
            object : X509TrustManager {
                override fun checkClientTrusted(
                    chain: Array<out X509Certificate>?,
                    authType: String?,
                ) = Unit

                override fun checkServerTrusted(
                    chain: Array<out X509Certificate>?,
                    authType: String?,
                ) = Unit

                override fun getAcceptedIssuers(): Array<X509Certificate> = emptyArray()
            }
        val context = SSLContext.getInstance("TLS")
        context.init(null, arrayOf<TrustManager>(trust), SecureRandom())
        return base
            .newBuilder()
            .sslSocketFactory(context.socketFactory, trust)
            .hostnameVerifier { host, _ -> host.equals(CLINIC_HOST, ignoreCase = true) }
            .build()
    }
}
