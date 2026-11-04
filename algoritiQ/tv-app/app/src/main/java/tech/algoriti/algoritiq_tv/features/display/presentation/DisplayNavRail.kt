/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.tv.material3.Button
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import tech.algoriti.algoritiq_tv.R
import tech.algoriti.algoritiq_tv.core.navigation.TvRoutes

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun DisplayNavRail(onNavigate: (String) -> Unit) {
    Column(
        modifier =
            Modifier
                .width(200.dp)
                .fillMaxHeight()
                .padding(16.dp),
    ) {
        NavButton(R.string.nav_setup_audio, TvRoutes.SetupAudio, onNavigate)
        NavButton(R.string.nav_display_idle, TvRoutes.DisplayIdle, onNavigate)
        NavButton(R.string.nav_display_live, TvRoutes.DisplayLive, onNavigate)
        NavButton(R.string.nav_display_disconnected, TvRoutes.DisplayDisconnected, onNavigate)
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun NavButton(
    labelRes: Int,
    route: String,
    onNavigate: (String) -> Unit,
) {
    Button(onClick = { onNavigate(route) }, modifier = Modifier.padding(vertical = 4.dp)) {
        Text(text = stringResource(labelRes))
    }
}
