/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.tv.material3.Button
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import tech.algoriti.algoritiq_tv.R

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun DisplayIdleScreen(
    onSimulateLive: () -> Unit,
    onSimulateDisconnect: () -> Unit,
) {
    DisplayBoardLayout(
        state = DisplaySampleData.idle,
        footerActions = {
            DevDisplayActions(onSimulateLive, onSimulateDisconnect)
        },
    )
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun DisplayLiveScreen(onSimulateDisconnect: () -> Unit) {
    DisplayBoardLayout(
        state = DisplaySampleData.live,
        footerActions = {
            DevDisplayActions(onSimulateDisconnect = onSimulateDisconnect)
        },
    )
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun DisplayDisconnectedScreen(onSimulateReconnect: () -> Unit) {
    DisplayBoardLayout(
        state = DisplaySampleData.disconnected,
        footerActions = {
            Button(onClick = onSimulateReconnect, modifier = Modifier.padding(top = 8.dp)) {
                Text(text = stringResource(R.string.display_connected))
            }
        },
    )
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun DevDisplayActions(
    onSimulateLive: (() -> Unit)? = null,
    onSimulateDisconnect: (() -> Unit)? = null,
) {
    if (onSimulateLive != null) {
        Button(onClick = onSimulateLive, modifier = Modifier.padding(top = 8.dp)) {
            Text(text = stringResource(R.string.nav_display_live))
        }
    }
    if (onSimulateDisconnect != null) {
        Button(onClick = onSimulateDisconnect, modifier = Modifier.padding(top = 8.dp)) {
            Text(text = stringResource(R.string.nav_display_disconnected))
        }
    }
}
