/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.network

import org.junit.Test
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull

class TabletAddressTest {
    @Test
    fun `should accept a plain address`() {
        assertEquals("192.168.1.22", TabletAddress.parse("192.168.1.22"))
    }

    @Test
    fun `should ignore spaces around and inside`() {
        assertEquals("192.168.1.22", TabletAddress.parse("  192. 168.1.22 "))
    }

    @Test
    fun `should read Bengali digits`() {
        assertEquals("192.168.1.22", TabletAddress.parse("১৯২.১৬৮.১.২২"))
    }

    @Test
    fun `should refuse what is not an address`() {
        assertNull(TabletAddress.parse(""))
        assertNull(TabletAddress.parse("192.168.1"))
        assertNull(TabletAddress.parse("192.168.1.256"))
        assertNull(TabletAddress.parse("192.168.1.22:8443"))
        assertNull(TabletAddress.parse("algoritiq.local"))
        assertNull(TabletAddress.parse("0.0.0.0"))
        assertNull(TabletAddress.parse("1..2.3"))
    }
}
