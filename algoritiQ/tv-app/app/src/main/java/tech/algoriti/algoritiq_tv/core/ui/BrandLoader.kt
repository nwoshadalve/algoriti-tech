/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.ui

import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlin.math.max
import kotlin.math.min

private const val DotCount = 3
private const val GapInDots = 0.8f
private const val WidthInDots = DotCount + (DotCount - 1) * GapInDots
private const val Rise = 0.2f
private const val Fall = 0.4f
private const val CycleMs = 1200

/** Three-dot loader aligned with the tablet app's [BrandLoader]. */
@Composable
fun BrandLoader(
    modifier: Modifier = Modifier,
    dotSize: Dp = 14.dp,
    lit: Color = Color(0xFF64B5F6),
    idle: Color = Color(0xFF546E7A),
) {
    val preview = LocalInspectionMode.current
    val progress =
        if (preview) {
            1f / 3f + Rise
        } else {
            val transition = rememberInfiniteTransition(label = "brand_loader")
            transition.animateFloat(
                initialValue = 0f,
                targetValue = 1f,
                animationSpec =
                    infiniteRepeatable(
                        animation = tween(CycleMs, easing = LinearEasing),
                        repeatMode = RepeatMode.Restart,
                    ),
                label = "brand_loader_progress",
            ).value
        }

    val width = dotSize * WidthInDots
    val height = dotSize * 1.5f
    Canvas(modifier = modifier.size(width, height)) {
        val d = size.width / WidthInDots
        val baseline = size.height - d / 2f
        for (i in 0 until DotCount) {
            val phase = (progress - i.toFloat() / DotCount) % 1f
            val glow = easeInOut(intensity(phase))
            val center =
                Offset(
                    x = d / 2f + i * d * (1f + GapInDots),
                    y = baseline - glow * d * 0.4f,
                )
            drawCircle(color = lerp(idle, lit, glow), radius = d / 2f, center = center)
        }
    }
}

private fun intensity(phase: Float): Float {
    val p = if (phase < 0f) phase + 1f else phase
    return when {
        p < Rise -> p / Rise
        p < Rise + Fall -> 1f - (p - Rise) / Fall
        else -> 0f
    }
}

private fun easeInOut(t: Float): Float {
    val x = min(1f, maxOf(0f, t))
    return if (x < 0.5f) 2f * x * x else 1f - (-2f * x + 2f).let { it * it } / 2f
}
