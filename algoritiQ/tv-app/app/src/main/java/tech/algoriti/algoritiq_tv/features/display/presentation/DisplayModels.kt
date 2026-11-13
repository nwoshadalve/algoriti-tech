/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

data class QueueTypeBoard(
    val labelBn: String,
    val waitingSerials: List<Int>,
    /** Seconds each of [waitingSerials] had waited when this was made, in the same order. */
    val waitedSeconds: List<Int> = emptyList(),
    val hiddenCount: Int = 0,
)

/** A token being called now and the queue it belongs to. */
data class CalledToken(
    val serial: Int,
    val queueLabelBn: String = "",
    /** False while it is on the board but not yet announced: the tile is outlined in orange until it is. */
    val announced: Boolean = true,
)

data class DisplayBoardState(
    /** The token called most recently: the one the board flashes. */
    val calledSerial: Int? = null,
    val calledTypeLabelBn: String? = null,
    /** Every token being called now, one per queue at most, in the queues' order. */
    val calls: List<CalledToken> = emptyList(),
    /** Goes up on every call, a recall of the same number included, so the board can show it again. */
    val callPulse: Int = 0,
    val queueTypes: List<QueueTypeBoard> = emptyList(),
    val doctorNameBn: String = "",
    val doctorDegrees: String = "",
    val doctorDesignation: String = "",
    val doctorSpecialty: String = "",
    val doctorWorkplace: String = "",
    val doctorRegistration: String = "",
    val chamberNameBn: String = "",
    val chamberLocation: String = "",
    val chamberPhone: String = "",
    /** Where the doctor's photo is on the tablet (a path), and a number that changes with the photo. */
    val photoPath: String = "",
    val photoVersion: Int = 0,
    val chamberId: String = "",
    val sessionOpen: Boolean = false,
    val connected: Boolean = true,
    val lastUpdateLabel: String = "",
    /** When this arrived, so the waiting times can count on by themselves between updates. */
    val receivedAtMs: Long = 0L,
)

object DisplaySampleData {
    val idle =
        DisplayBoardState(
            calledSerial = null,
            queueTypes =
                listOf(
                    QueueTypeBoard("নিয়মিত", listOf(12, 13, 14, 15, 16), hiddenCount = 3),
                    QueueTypeBoard("রিপোর্ট", listOf(4, 5)),
                    QueueTypeBoard("ড্রেসিং", listOf(2)),
                ),
            doctorNameBn = "ডা. মো. জাহিদুল হক খান",
            chamberNameBn = "আল-খিদমাহ্ মেডিকেল সার্ভিসেস (প্রাঃ), চাঁদপুর",
            connected = true,
        )

    val live =
        idle.copy(
            calledSerial = 11,
            calledTypeLabelBn = "নিয়মিত",
            calls = listOf(CalledToken(11, "নিয়মিত")),
        )

    val disconnected =
        live.copy(
            connected = false,
            lastUpdateLabel = "১০:৩০",
        )
}
