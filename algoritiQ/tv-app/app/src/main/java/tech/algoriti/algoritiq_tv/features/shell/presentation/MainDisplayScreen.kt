/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.shell.presentation

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.ImageBitmap
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardLayout
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState

@Composable
fun MainDisplayScreen(
    state: DisplayBoardState,
    doctorPhoto: ImageBitmap? = null,
) {
    DisplayBoardLayout(state = state, doctorPhoto = doctorPhoto)
}
