/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.domain

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class TvDisplayMapperTest {
    private fun map(text: String) =
        TvDisplayMapper.fromDisplayJson(Json.parseToJsonElement(text).jsonObject, connected = true, lastUpdateLabel = "")

    @Test
    fun readsAnOpenChamberWhereNobodyIsCalled() {
        // The shape the tablet sends: `called` is null until someone is called.
        val state =
            map(
                """{"chamberId":"c1","sessionOpen":true,"doctor":{"name":"ডা. রহিম"},"chamber":{"name":"কক্ষ ১"},
                "queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"}],"called":null,"waiting":{"regular":[1001,1002]}}""",
            )

        assertNull(state.calledSerial)
        assertEquals(listOf(1001, 1002), state.queueTypes.single().waitingSerials)
        assertEquals("ডা. রহিম", state.doctorNameBn)
    }

    @Test
    fun readsTheCalledSerialAndItsQueue() {
        val state =
            map(
                """{"queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"}],
                "called":{"tokenId":"t","queueTypeId":"regular","serial":1003},"waiting":{}}""",
            )

        assertEquals(1003, state.calledSerial)
        assertEquals("নিয়মিত", state.calledTypeLabelBn)
    }

    @Test
    fun copesWithEveryOptionalPartBeingNull() {
        val state = map("""{"sessionOpen":false,"doctor":null,"chamber":null,"queueTypes":null,"called":null,"waiting":null}""")

        assertNull(state.calledSerial)
        assertEquals(emptyList<Any>(), state.queueTypes)
        assertEquals("", state.doctorNameBn)
    }

    @Test
    fun showsOnlyTheFirstWaitingAndCountsTheRest() {
        val state =
            map("""{"queueTypes":[{"id":"r","bengaliName":"র"}],"waiting":{"r":[1,2,3,4,5,6,7]}}""")

        assertEquals(listOf(1, 2, 3, 4), state.queueTypes.single().waitingSerials)
        assertEquals(3, state.queueTypes.single().hiddenCount)
    }

    @Test
    fun readsTheDoctorAndChamberDetails() {
        val state =
            map(
                """{"chamberId":"c1","sessionOpen":true,
                "doctor":{"id":"d1","name":"ডা. রহিম","degrees":["এমবিবিএস","এফসিপিএস"],"designation":"অধ্যাপক",
                  "specialty":"মেডিসিন","workplace":"ঢাকা মেডিকেল","registrationNumber":"A-123","photoVersion":42,
                  "photoUrl":"/api/v1/tv/doctor-photo?doctor=d1"},
                "chamber":{"name":"কক্ষ ১","location":"ঢাকা","phone":"01711000111"},
                "queueTypes":[],"called":null,"waiting":{}}""",
            )

        assertEquals("এমবিবিএস · এফসিপিএস", state.doctorDegrees)
        assertEquals("অধ্যাপক", state.doctorDesignation)
        assertEquals("মেডিসিন", state.doctorSpecialty)
        assertEquals("ঢাকা মেডিকেল", state.doctorWorkplace)
        assertEquals("A-123", state.doctorRegistration)
        assertEquals("ঢাকা", state.chamberLocation)
        assertEquals("01711000111", state.chamberPhone)
        assertEquals("/api/v1/tv/doctor-photo?doctor=d1", state.photoPath)
        assertEquals(42, state.photoVersion)
        assertEquals("c1", state.chamberId)
        assertEquals(true, state.sessionOpen)
    }

    private fun display(
        id: String,
        open: Boolean,
    ) = Json.parseToJsonElement("""{"chamberId":"$id","sessionOpen":$open}""").jsonObject

    @Test
    fun showsTheChamberWhoseSessionIsOpen() {
        val chosen = ChamberDisplays()
        chosen.update(display("c1", open = false))
        chosen.update(display("c2", open = true))

        assertEquals("c2", chosen.current()?.get("chamberId")?.toString()?.trim('"'))
    }

    @Test
    fun followsTheLatestWhenNoSessionIsOpen() {
        val chosen = ChamberDisplays()
        chosen.update(display("c1", open = false))
        chosen.update(display("c2", open = false))

        assertEquals("c2", chosen.current()?.get("chamberId")?.toString()?.trim('"'))
    }

    @Test
    fun movesToTheOtherChamberWhenTheOpenSessionEnds() {
        val chosen = ChamberDisplays()
        chosen.update(display("c1", open = true))
        chosen.update(display("c2", open = false))
        chosen.update(display("c1", open = false))
        chosen.update(display("c2", open = true))

        assertEquals("c2", chosen.current()?.get("chamberId")?.toString()?.trim('"'))
    }

    @Test
    fun hasNothingBeforeAnythingArrives() {
        assertNull(ChamberDisplays().current())
    }
}
