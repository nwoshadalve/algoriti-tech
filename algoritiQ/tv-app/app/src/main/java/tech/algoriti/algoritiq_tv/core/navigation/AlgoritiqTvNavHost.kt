/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.navigation

import androidx.compose.foundation.layout.Box
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import tech.algoriti.algoritiq_tv.features.shell.application.TvShellViewModel
import tech.algoriti.algoritiq_tv.features.shell.presentation.ConnectingScreen
import tech.algoriti.algoritiq_tv.features.shell.presentation.MainDisplayScreen
import tech.algoriti.algoritiq_tv.features.shell.presentation.TestScreenOverlay

/**
 * Nothing received from the tablet yet: connecting. Otherwise the board. A test screen from the tablet covers any of them for a few seconds.
 */
@Composable
fun AlgoritiqTvNavHost(viewModel: TvShellViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    Box {
        when {
            uiState.showMain -> MainDisplayScreen(state = uiState.display, doctorPhoto = uiState.doctorPhoto)
            else -> ConnectingScreen()
        }
        uiState.testScreen?.let { TestScreenOverlay(it) }
    }
}
