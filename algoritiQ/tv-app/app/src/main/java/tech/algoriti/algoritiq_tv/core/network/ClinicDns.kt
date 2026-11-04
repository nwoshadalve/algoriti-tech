/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import android.content.Context
import android.net.wifi.WifiManager
import java.net.DatagramPacket
import java.net.Inet4Address
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.MulticastSocket
import java.net.SocketTimeoutException
import javax.inject.Inject
import javax.inject.Singleton
import okhttp3.Dns
import dagger.hilt.android.qualifiers.ApplicationContext
import timber.log.Timber

/**
 * Finds the tablet by its name, `algoritiq.local`, with no address saved anywhere. Android does not
 * resolve `.local` names itself, so this asks the local network directly (multicast DNS): the
 * tablet answers to its own name. A normal lookup is tried first, then the multicast question,
 * asked a few times because Wi-Fi drops the odd multicast packet. Every other name goes to the
 * system as usual.
 */
@Singleton
class ClinicDns
    @Inject
    constructor(
        @ApplicationContext private val context: Context,
    ) : Dns {
        @Volatile private var lastKnown: InetAddress? = null

        override fun lookup(hostname: String): List<InetAddress> {
            if (!hostname.equals(ClinicTls.CLINIC_HOST, ignoreCase = true)) return Dns.SYSTEM.lookup(hostname)
            DevClinicDns.emulatorHost()?.let { return listOf(it) }
            runCatching { Dns.SYSTEM.lookup(hostname) }.getOrNull()?.takeIf { it.isNotEmpty() }?.let { return it }
            val found = ask(hostname) ?: lastKnown
            if (found == null) throw java.net.UnknownHostException("$hostname: the tablet did not answer")
            lastKnown = found
            return listOf(found)
        }

        private fun ask(hostname: String): InetAddress? {
            val wifi = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
            val lock = wifi?.createMulticastLock("algoritiq-mdns")?.apply { setReferenceCounted(false) }
            lock?.acquire()
            try {
                MulticastSocket(null).use { socket ->
                    socket.reuseAddress = true
                    socket.bind(InetSocketAddress(MDNS_PORT))
                    val group = InetAddress.getByName(MDNS_GROUP)
                    socket.joinGroup(group)
                    socket.soTimeout = LISTEN_MS
                    val question = MdnsMessage.query(hostname)
                    repeat(ATTEMPTS) {
                        socket.send(DatagramPacket(question, question.size, group, MDNS_PORT))
                        val deadline = System.currentTimeMillis() + ATTEMPT_MS
                        val buffer = ByteArray(1500)
                        while (System.currentTimeMillis() < deadline) {
                            val packet = DatagramPacket(buffer, buffer.size)
                            try {
                                socket.receive(packet)
                            } catch (_: SocketTimeoutException) {
                                continue
                            }
                            val address = MdnsMessage.addressOf(buffer, packet.length, hostname)
                            if (address is Inet4Address) return address
                        }
                    }
                }
            } catch (e: Exception) {
                Timber.w(e, "mdns_lookup_failed")
            } finally {
                lock?.release()
            }
            return null
        }

        private companion object {
            const val MDNS_GROUP = "224.0.0.251"
            const val MDNS_PORT = 5353
            const val ATTEMPTS = 3
            const val ATTEMPT_MS = 1_500L
            const val LISTEN_MS = 300
        }
    }
