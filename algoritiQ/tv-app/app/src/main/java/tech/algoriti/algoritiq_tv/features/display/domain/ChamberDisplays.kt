/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.domain

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull

/**
 * The latest display the tablet sent for each chamber. The tablet runs one session at a time, so the
 * TV shows the chamber whose session is open; when none is open it stays on the one updated last.
 */
class ChamberDisplays {
    private val latest = LinkedHashMap<String, JsonObject>()

    fun update(display: JsonObject) {
        val id = (display["chamberId"] as? JsonPrimitive)?.contentOrNull.orEmpty()
        // Re-insert so the map stays in update order: the last entry is the latest.
        latest.remove(id)
        latest[id] = display
    }

    /** What the TV should show now, or null before anything has arrived. */
    fun current(): JsonObject? =
        latest.values.lastOrNull { ((it["sessionOpen"] as? JsonPrimitive)?.booleanOrNull) == true }
            ?: latest.values.lastOrNull()
}
