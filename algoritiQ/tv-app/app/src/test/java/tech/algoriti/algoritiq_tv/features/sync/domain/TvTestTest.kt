/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.sync.domain

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class TvTestTest {
    private fun payload(text: String) = Json.parseToJsonElement(text).jsonObject

    @Test
    fun readsAScreenOnlyTest() {
        val command = TvTestCommand.from(payload("""{"chamberId":"c1","testId":"x1"}"""))

        assertEquals(TvTestCommand("x1", null), command)
    }

    @Test
    fun readsASoundTest() {
        val command =
            TvTestCommand.from(payload("""{"testId":"x1","announcementUrl":"/api/v1/tv/test-announcement"}"""))

        assertEquals(TvTestCommand("x1", "/api/v1/tv/test-announcement"), command)
    }

    @Test
    fun ignoresACommandWithoutAnId() {
        assertNull(TvTestCommand.from(payload("""{"announcementUrl":"/x"}""")))
        assertNull(TvTestCommand.from(payload("""{"testId":" "}""")))
        assertNull(TvTestCommand.from(null))
    }

    @Test
    fun replyTellsWhatTheTvDid() {
        val reply = payload(TvTestReply.json("x1", TvTestReply.AUDIO_FAILED, "ERROR_CODE_IO"))

        assertEquals("ack", reply["type"]!!.jsonPrimitive.content)
        assertEquals("tv.test", reply["name"]!!.jsonPrimitive.content)
        assertEquals("x1", reply["testId"]!!.jsonPrimitive.content)
        assertEquals("shown", reply["display"]!!.jsonPrimitive.content)
        assertEquals("failed", reply["audio"]!!.jsonPrimitive.content)
        assertEquals("ERROR_CODE_IO", reply["error"]!!.jsonPrimitive.content)
    }

    @Test
    fun replyOmitsTheErrorWhenThereIsNone() {
        val reply = payload(TvTestReply.json("x1", TvTestReply.AUDIO_PLAYED))

        assertNull(reply["error"])
        assertEquals("played", reply["audio"]!!.jsonPrimitive.content)
    }
}
