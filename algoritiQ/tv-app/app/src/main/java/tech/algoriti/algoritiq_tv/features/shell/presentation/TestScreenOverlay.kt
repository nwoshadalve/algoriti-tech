/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.shell.presentation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import tech.algoriti.algoritiq_tv.R
import tech.algoriti.algoritiq_tv.features.sync.domain.SoundProgress
import tech.algoriti.algoritiq_tv.features.sync.domain.TestScreenState

private val Navy = Color(0xFF0B1F3A)
private val Good = Color(0xFF3DDC97)
private val Problem = Color(0xFFFF8A70)

/**
 * The screen staff ask for from the tablet to check the TV: brand navy over the whole board, so it
 * is clearly not a real call, saying the display works and how the sound went.
 */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun TestScreenOverlay(state: TestScreenState) {
    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .background(Navy)
                .padding(48.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = stringResource(R.string.test_title),
            color = Color.White,
            fontSize = 40.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(text = stringResource(R.string.test_display_ok), color = Good, fontSize = 28.sp)
        soundText(state.sound)?.let { (res, color) ->
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = stringResource(res), color = color, fontSize = 28.sp, textAlign = TextAlign.Center)
        }
    }
}

private fun soundText(sound: SoundProgress): Pair<Int, Color>? =
    when (sound) {
        SoundProgress.NotRequested -> null
        SoundProgress.Playing -> R.string.test_sound_playing to Color.White
        SoundProgress.Played -> R.string.test_sound_ok to Good
        SoundProgress.Failed -> R.string.test_sound_failed to Problem
    }
