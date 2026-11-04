/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import java.io.ByteArrayOutputStream
import java.net.InetAddress

/**
 * The little of multicast DNS (RFC 6762) a TV needs to find the tablet by its `.local` name: ask
 * for the address of one name, and read an address for it out of an answer.
 */
object MdnsMessage {
    private const val HEADER = 12
    private const val TYPE_A = 1
    private const val MAX_POINTER_JUMPS = 16

    /** A question for the IPv4 address (an `A` record) of [host]. */
    fun query(host: String): ByteArray {
        val out = ByteArrayOutputStream()
        out.write(byteArrayOf(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0))
        host.split('.').forEach { label ->
            val bytes = label.toByteArray(Charsets.UTF_8)
            out.write(bytes.size)
            out.write(bytes)
        }
        out.write(0)
        out.write(byteArrayOf(0, TYPE_A.toByte(), 0, 1))
        return out.toByteArray()
    }

    /**
     * The IPv4 address [packet] gives for [host], or null when it gives none (another name, another
     * record type, or a packet that is cut short or malformed). Never throws.
     */
    fun addressOf(
        packet: ByteArray,
        length: Int,
        host: String,
    ): InetAddress? =
        runCatching { read(packet, length, host.lowercase()) }.getOrNull()

    private fun read(
        packet: ByteArray,
        length: Int,
        host: String,
    ): InetAddress? {
        if (length < HEADER) return null
        val questions = u16(packet, 4)
        val records = u16(packet, 6) + u16(packet, 8) + u16(packet, 10)
        var at = HEADER
        repeat(questions) {
            at = skipName(packet, length, at) + 4
        }
        repeat(records) {
            val (name, afterName) = readName(packet, length, at)
            if (afterName + 10 > length) return null
            val type = u16(packet, afterName)
            val dataLength = u16(packet, afterName + 8)
            val data = afterName + 10
            if (data + dataLength > length) return null
            if (type == TYPE_A && dataLength == 4 && name.equals(host, ignoreCase = true)) {
                return InetAddress.getByAddress(packet.copyOfRange(data, data + 4))
            }
            at = data + dataLength
        }
        return null
    }

    private fun u16(
        packet: ByteArray,
        at: Int,
    ): Int = ((packet[at].toInt() and 0xFF) shl 8) or (packet[at + 1].toInt() and 0xFF)

    private fun skipName(
        packet: ByteArray,
        length: Int,
        start: Int,
    ): Int = readName(packet, length, start).second

    /** The dotted name at [start], and where the data after it begins. Follows compression pointers. */
    private fun readName(
        packet: ByteArray,
        length: Int,
        start: Int,
    ): Pair<String, Int> {
        val labels = mutableListOf<String>()
        var at = start
        var end = -1
        var jumps = 0
        while (true) {
            if (at >= length) error("cut short")
            val size = packet[at].toInt() and 0xFF
            when {
                size == 0 -> {
                    if (end < 0) end = at + 1
                    return labels.joinToString(".") to end
                }
                size and 0xC0 == 0xC0 -> {
                    if (at + 1 >= length) error("cut short")
                    if (end < 0) end = at + 2
                    if (++jumps > MAX_POINTER_JUMPS) error("pointer loop")
                    at = ((size and 0x3F) shl 8) or (packet[at + 1].toInt() and 0xFF)
                }
                else -> {
                    if (at + 1 + size > length) error("cut short")
                    labels += String(packet, at + 1, size, Charsets.UTF_8)
                    at += 1 + size
                }
            }
        }
    }
}
