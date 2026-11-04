/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.core.ui

import androidx.compose.foundation.Image
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import tech.algoriti.algoritiq_tv.R

/**
 * The AlgoritiQ wordmark (`branding/logo/algoritiq/svg`). [reversed] is the white version for dark
 * backgrounds. The drawables hold the lettering as outlines, so no font is needed.
 */
@Composable
fun AlgoritiqWordmark(
    modifier: Modifier = Modifier,
    reversed: Boolean = false,
) {
    Image(
        painter =
            painterResource(
                if (reversed) R.drawable.algoritiq_wordmark_reversed else R.drawable.algoritiq_wordmark,
            ),
        contentDescription = stringResource(R.string.app_name),
        modifier = modifier,
    )
}
