/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.domain

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.jsonPrimitive
import tech.algoriti.algoritiq_tv.features.display.presentation.CalledToken
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState
import tech.algoriti.algoritiq_tv.features.display.presentation.QueueTypeBoard

object TvDisplayMapper {
    private const val MAX_WAITING_VISIBLE = 4

    fun fromDisplayJson(
        display: JsonObject,
        connected: Boolean,
        lastUpdateLabel: String,
        receivedAtMs: Long = System.currentTimeMillis(),
    ): DisplayBoardState {
        val queueTypesJson = (display["queueTypes"] as? JsonArray).orEmpty()
        val typeLabels =
            queueTypesJson.associate { type ->
                val obj = type.asObject()
                val id = obj?.string("id").orEmpty()
                val bn = obj?.string("bengaliName") ?: id
                id to bn
            }
        val waitingObj = display["waiting"].asObject()
        val waitedObj = display["waitedSeconds"].asObject()
        val queueBoards =
            queueTypesJson.map { type ->
                val obj = type.asObject()
                val id = obj?.string("id").orEmpty()
                val label = obj?.string("bengaliName") ?: id
                val serials =
                    (waitingObj?.get(id) as? JsonArray)
                        ?.mapNotNull { (it as? JsonPrimitive)?.intOrNull }
                        .orEmpty()
                val visible = serials.take(MAX_WAITING_VISIBLE)
                val waited =
                    (waitedObj?.get(id) as? JsonArray)
                        ?.map { (it as? JsonPrimitive)?.intOrNull ?: 0 }
                        .orEmpty()
                QueueTypeBoard(
                    labelBn = label,
                    waitingSerials = visible,
                    waitedSeconds = visible.indices.map { waited.getOrElse(it) { 0 } },
                    hiddenCount = (serials.size - visible.size).coerceAtLeast(0),
                )
            }
        val called = display["called"].asObject()
        val calledSerial = called?.int("serial")
        val calledTypeId = called?.string("queueTypeId")
        // Every call in the queues' order; a tablet that only knows one call sends just `called`.
        val listed = (display["calledList"] as? JsonArray)?.mapNotNull { it.asObject() }.orEmpty()
        val calls =
            (if (listed.isEmpty() && called != null) listOf(called) else listed).mapNotNull { call ->
                call.int("serial")?.let { serial ->
                    CalledToken(
                        serial,
                        typeLabels[call.string("queueTypeId").orEmpty()].orEmpty(),
                        announced = (call["announced"] as? JsonPrimitive)?.booleanOrNull ?: true,
                    )
                }
            }
        val doctor = display["doctor"].asObject()
        val chamber = display["chamber"].asObject()
        return DisplayBoardState(
            calledSerial = calledSerial,
            calledTypeLabelBn = calledTypeId?.let { typeLabels[it] },
            calls = calls,
            queueTypes = queueBoards,
            doctorNameBn = doctor?.string("name").orEmpty(),
            doctorDegrees = (doctor?.get("degrees") as? JsonArray).orEmpty().mapNotNull { (it as? JsonPrimitive)?.contentOrNull }.joinToString(" · "),
            doctorDesignation = doctor?.string("designation").orEmpty(),
            doctorSpecialty = doctor?.string("specialty").orEmpty(),
            doctorWorkplace = doctor?.string("workplace").orEmpty(),
            doctorRegistration = doctor?.string("registrationNumber").orEmpty(),
            chamberNameBn = chamber?.string("name").orEmpty(),
            chamberLocation = chamber?.string("location").orEmpty(),
            chamberPhone = chamber?.string("phone").orEmpty(),
            photoPath = doctor?.string("photoUrl").orEmpty(),
            photoVersion = doctor?.int("photoVersion") ?: 0,
            chamberId = display.string("chamberId").orEmpty(),
            sessionOpen = (display["sessionOpen"] as? JsonPrimitive)?.booleanOrNull == true,
            connected = connected,
            lastUpdateLabel = lastUpdateLabel,
            receivedAtMs = receivedAtMs,
        )
    }

    /** An object, or null for anything else: the tablet sends `null` for what is not there. */
    private fun JsonElement?.asObject(): JsonObject? = this as? JsonObject

    private fun JsonObject.string(key: String): String? = (this[key] as? JsonPrimitive)?.contentOrNull

    private fun JsonObject.int(key: String): Int? = (this[key] as? JsonPrimitive)?.intOrNull
}
