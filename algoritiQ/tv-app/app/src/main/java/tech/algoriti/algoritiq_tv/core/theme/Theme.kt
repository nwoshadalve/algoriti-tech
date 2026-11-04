/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

/** Waiting-room light theme only (see tv-app/docs/standards/ui.md). */
private val ClinicLightColors =
    lightColorScheme(
        primary = Color(0xFF1B5E20),
        onPrimary = Color.White,
        tertiary = Color(0xFFFF5C39),
        onTertiary = Color.White,
        background = Color(0xFFF5F5F0),
        onBackground = Color(0xFF1A1A1A),
        surface = Color(0xFFF5F5F0),
        onSurface = Color(0xFF1A1A1A),
        onSurfaceVariant = Color(0xFF546E7A),
        outline = Color(0xFF90A4AE),
        outlineVariant = Color(0xFFB0BEC5),
    )

@Composable
fun AlgoritiqTvTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = ClinicLightColors,
        content = content,
    )
}
