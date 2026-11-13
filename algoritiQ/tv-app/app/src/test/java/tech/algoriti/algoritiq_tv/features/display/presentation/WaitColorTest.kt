/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

import androidx.compose.ui.graphics.Color
import org.junit.Assert.assertEquals
import org.junit.Test

class WaitColorTest {
    private val calm = Color(0xFF16A34A)
    private val long = Color(0xFFD97706)
    private val veryLong = Color(0xFFDC2626)

    @Test
    fun isCalmUnderTenMinutes() {
        assertEquals(calm, waitColor(0))
        assertEquals(calm, waitColor(9 * 60 + 59))
    }

    @Test
    fun turnsAmberFromTenMinutes() {
        assertEquals(long, waitColor(10 * 60))
        assertEquals(long, waitColor(29 * 60 + 59))
    }

    @Test
    fun turnsRedFromThirtyMinutes() {
        assertEquals(veryLong, waitColor(30 * 60))
        assertEquals(veryLong, waitColor(3 * 3600))
    }
}
