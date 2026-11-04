/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.domain

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class EventSequenceTrackerTest {
    @Test
    fun acceptsMonotonicSequences() {
        val tracker = EventSequenceTracker()
        tracker.reset(10L)
        assertTrue(tracker.accept(11L))
        assertFalse(tracker.accept(11L))
    }

    @Test
    fun detectsGap() {
        val tracker = EventSequenceTracker()
        tracker.reset(5L)
        assertTrue(tracker.hasGap(7L))
        assertFalse(tracker.accept(7L))
    }
}
