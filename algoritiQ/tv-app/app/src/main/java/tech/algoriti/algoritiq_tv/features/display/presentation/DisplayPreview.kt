/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import kotlinx.coroutines.delay

/** Plays sample calls, one every few seconds, for reviewing the board's motion. Debug builds only. */
@Composable
fun DisplayPreview() {
    var step by remember { mutableIntStateOf(0) }
    LaunchedEffect(Unit) {
        while (true) {
            delay(4_000)
            step++
        }
    }
    val base = DisplaySampleData.idle
    val waiting = (12 + step..15 + step).toList()
    val state =
        base.copy(
            calledSerial = if (step == 0) null else 10 + step,
            calledTypeLabelBn = if (step == 0) null else "নিয়মিত",
            queueTypes = listOf(base.queueTypes[0].copy(waitingSerials = waiting), base.queueTypes[1], base.queueTypes[2]),
        )
    DisplayBoardLayout(state = state)
}
