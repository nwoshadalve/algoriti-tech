/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.setup.presentation

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Button
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import tech.algoriti.algoritiq_tv.R

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun SetupAudioScreen(onContinue: () -> Unit) {
    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .padding(48.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(text = stringResource(R.string.setup_audio_title), fontSize = 36.sp, fontWeight = FontWeight.Bold)
        Spacer(modifier = Modifier.height(16.dp))
        Text(text = stringResource(R.string.setup_audio_subtitle), fontSize = 22.sp)
        Spacer(modifier = Modifier.height(32.dp))
        Button(onClick = { /* TODO: play test clip from API */ }) {
            Text(text = stringResource(R.string.setup_audio_test))
        }
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = onContinue) {
            Text(text = stringResource(R.string.setup_audio_continue))
        }
    }
}
