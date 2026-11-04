/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.domain

/**
 * Tracks monotonic WebSocket eventSequence values per OpenAPI `/ws/live`.
 */
class EventSequenceTracker {
    private var lastSequence: Long = 0L

    fun reset(newBaseline: Long = 0L) {
        lastSequence = newBaseline
    }

    /**
     * @return true if [sequence] is the next expected event and was applied.
     */
    fun accept(sequence: Long): Boolean {
        if (sequence <= lastSequence) {
            return false
        }
        if (lastSequence != 0L && sequence > lastSequence + 1) {
            return false
        }
        lastSequence = sequence
        return true
    }

    fun hasGap(sequence: Long): Boolean = lastSequence != 0L && sequence > lastSequence + 1
}
