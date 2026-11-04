/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import java.io.ByteArrayOutputStream
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class MdnsMessageTest {
    private fun u16(value: Int) = byteArrayOf((value shr 8).toByte(), value.toByte())

    private fun name(host: String): ByteArray {
        val out = ByteArrayOutputStream()
        host.split('.').forEach {
            out.write(it.length)
            out.write(it.toByteArray())
        }
        out.write(0)
        return out.toByteArray()
    }

    /** A response with one record, as the tablet sends it: no question, one answer. */
    private fun response(
        host: String,
        type: Int,
        rdata: ByteArray,
    ): ByteArray {
        val out = ByteArrayOutputStream()
        out.write(byteArrayOf(0, 0, 0x84.toByte(), 0, 0, 0, 0, 1, 0, 0, 0, 0))
        out.write(name(host))
        out.write(u16(type))
        out.write(u16(0x8001))
        out.write(byteArrayOf(0, 0, 0, 120))
        out.write(u16(rdata.size))
        out.write(rdata)
        return out.toByteArray()
    }

    @Test
    fun questionAsksForTheAddressOfTheName() {
        val packet = MdnsMessage.query("algoritiq.local")

        val expected =
            byteArrayOf(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0) + name("algoritiq.local") + u16(1) + u16(1)
        assertArrayEquals(expected, packet)
    }

    @Test
    fun readsTheAddressOfTheRightName() {
        val packet = response("algoritiq.local", 1, byteArrayOf(192.toByte(), 168.toByte(), 1, 110))

        val address = MdnsMessage.addressOf(packet, packet.size, "algoritiq.local")

        assertEquals("192.168.1.110", address?.hostAddress)
    }

    @Test
    fun ignoresTheCaseOfTheName() {
        val packet = response("AlgoritiQ.local", 1, byteArrayOf(10, 0, 0, 7))

        assertEquals("10.0.0.7", MdnsMessage.addressOf(packet, packet.size, "algoritiq.local")?.hostAddress)
    }

    @Test
    fun ignoresAnotherName() {
        val packet = response("printer.local", 1, byteArrayOf(10, 0, 0, 7))

        assertNull(MdnsMessage.addressOf(packet, packet.size, "algoritiq.local"))
    }

    @Test
    fun ignoresARecordOfAnotherType() {
        val packet = response("algoritiq.local", 28, ByteArray(16))

        assertNull(MdnsMessage.addressOf(packet, packet.size, "algoritiq.local"))
    }

    @Test
    fun followsACompressedName() {
        // One question, then an answer whose name is a pointer back to the question's.
        val out = ByteArrayOutputStream()
        out.write(byteArrayOf(0, 0, 0x84.toByte(), 0, 0, 1, 0, 1, 0, 0, 0, 0))
        out.write(name("algoritiq.local"))
        out.write(u16(1))
        out.write(u16(1))
        out.write(byteArrayOf(0xC0.toByte(), 12))
        out.write(u16(1))
        out.write(u16(1))
        out.write(byteArrayOf(0, 0, 0, 120))
        out.write(u16(4))
        out.write(byteArrayOf(172.toByte(), 16, 0, 9))
        val packet = out.toByteArray()

        assertEquals("172.16.0.9", MdnsMessage.addressOf(packet, packet.size, "algoritiq.local")?.hostAddress)
    }

    @Test
    fun survivesGarbage() {
        assertNull(MdnsMessage.addressOf(ByteArray(0), 0, "algoritiq.local"))
        assertNull(MdnsMessage.addressOf(byteArrayOf(1, 2, 3), 3, "algoritiq.local"))
        val truncated = response("algoritiq.local", 1, byteArrayOf(1, 2, 3, 4)).copyOf(30)
        assertNull(MdnsMessage.addressOf(truncated, truncated.size, "algoritiq.local"))
    }

    @Test
    fun survivesANamePointerLoop() {
        val loop = byteArrayOf(0, 0, 0x84.toByte(), 0, 0, 0, 0, 1, 0, 0, 0, 0, 0xC0.toByte(), 12, 0, 1, 0, 1, 0, 0, 0, 1, 0, 4, 1, 2, 3, 4)

        assertNull(MdnsMessage.addressOf(loop, loop.size, "algoritiq.local"))
    }
}
