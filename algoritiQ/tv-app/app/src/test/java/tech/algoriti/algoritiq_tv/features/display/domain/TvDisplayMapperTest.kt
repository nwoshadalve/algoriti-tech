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
    fun readsHowLongEachWaitingSerialHasWaited() {
        val state =
            map(
                """{"queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"}],"called":null,
                "waiting":{"regular":[5,6,7]},"waitedSeconds":{"regular":[600,95]}}""",
            )

        // A serial the tablet sent no time for counts as just arrived.
        assertEquals(listOf(600, 95, 0), state.queueTypes.single().waitedSeconds)
    }

    @Test
    fun waitingTimesAreZeroWhenTheTabletSendsNone() {
        val state = map("""{"queueTypes":[{"id":"regular"}],"waiting":{"regular":[5]}}""")

        assertEquals(listOf(0), state.queueTypes.single().waitedSeconds)
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
    fun readsEveryCallGoingOnInTheQueuesOrder() {
        val state =
            map(
                """{"queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"},{"id":"report","bengaliName":"রিপোর্ট"}],
                "called":{"tokenId":"b","queueTypeId":"report","serial":201},
                "calledList":[{"tokenId":"a","queueTypeId":"regular","serial":104},
                {"tokenId":"b","queueTypeId":"report","serial":201}],"waiting":{}}""",
            )

        assertEquals(listOf(104, 201), state.calls.map { it.serial })
        assertEquals(listOf("নিয়মিত", "রিপোর্ট"), state.calls.map { it.queueLabelBn })
        // The newest call is the one that flashes.
        assertEquals(201, state.calledSerial)
    }

    @Test
    fun takesTheOneCallOfAnOlderTabletAsTheOnlyCall() {
        val state =
            map(
                """{"queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"}],
                "called":{"tokenId":"t","queueTypeId":"regular","serial":1003},"waiting":{}}""",
            )

        assertEquals(listOf(1003), state.calls.map { it.serial })
    }

    @Test
    fun knowsWhichCallsAreNotAnnouncedYet() {
        val state =
            map(
                """{"queueTypes":[{"id":"regular","bengaliName":"নিয়মিত"},{"id":"report","bengaliName":"রিপোর্ট"}],
                "called":{"tokenId":"b","queueTypeId":"report","serial":201},
                "calledList":[{"tokenId":"a","queueTypeId":"regular","serial":104,"announced":true},
                {"tokenId":"b","queueTypeId":"report","serial":201,"announced":false}],"waiting":{}}""",
            )

        assertEquals(listOf(true, false), state.calls.map { it.announced })
    }

    @Test
    fun hasNoCallsWhenNobodyIsCalled() {
        assertEquals(emptyList<Any>(), map("""{"queueTypes":[],"called":null,"calledList":[],"waiting":{}}""").calls)
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
