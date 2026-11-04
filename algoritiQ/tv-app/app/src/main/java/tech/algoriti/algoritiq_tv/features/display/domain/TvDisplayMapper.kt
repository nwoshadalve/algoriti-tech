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
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState
import tech.algoriti.algoritiq_tv.features.display.presentation.QueueTypeBoard

object TvDisplayMapper {
    private const val MAX_WAITING_VISIBLE = 4

    fun fromDisplayJson(
        display: JsonObject,
        connected: Boolean,
        lastUpdateLabel: String,
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
                QueueTypeBoard(
                    labelBn = label,
                    waitingSerials = visible,
                    hiddenCount = (serials.size - visible.size).coerceAtLeast(0),
                )
            }
        val called = display["called"].asObject()
        val calledSerial = called?.int("serial")
        val calledTypeId = called?.string("queueTypeId")
        val doctor = display["doctor"].asObject()
        val chamber = display["chamber"].asObject()
        return DisplayBoardState(
            calledSerial = calledSerial,
            calledTypeLabelBn = calledTypeId?.let { typeLabels[it] },
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
        )
    }

    /** An object, or null for anything else: the tablet sends `null` for what is not there. */
    private fun JsonElement?.asObject(): JsonObject? = this as? JsonObject

    private fun JsonObject.string(key: String): String? = (this[key] as? JsonPrimitive)?.contentOrNull

    private fun JsonObject.int(key: String): Int? = (this[key] as? JsonPrimitive)?.intOrNull
}
