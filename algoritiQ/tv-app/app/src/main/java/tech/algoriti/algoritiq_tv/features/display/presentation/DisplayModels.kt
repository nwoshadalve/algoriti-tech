/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

data class QueueTypeBoard(
    val labelBn: String,
    val waitingSerials: List<Int>,
    val hiddenCount: Int = 0,
)

data class DisplayBoardState(
    val calledSerial: Int? = null,
    val calledTypeLabelBn: String? = null,
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
        )

    val disconnected =
        live.copy(
            connected = false,
            lastUpdateLabel = "১০:৩০",
        )
}
