/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import dagger.hilt.android.AndroidEntryPoint
import tech.algoriti.algoritiq_tv.core.navigation.AlgoritiqTvNavHost
import tech.algoriti.algoritiq_tv.core.theme.AlgoritiqTvTheme
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayPreview

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        enableEdgeToEdge()
        WindowCompat.getInsetsController(window, window.decorView).apply {
            isAppearanceLightStatusBars = true
            isAppearanceLightNavigationBars = true
        }
        setContent {
            AlgoritiqTvTheme {
                // Debug builds only: `--es preview cycle` plays sample calls so the screen's motion can be
                // reviewed without touching real queue data. Real TVs never take this path.
                if (BuildConfig.DEBUG && intent.getStringExtra("preview") == "cycle") {
                    DisplayPreview()
                } else {
                    AlgoritiqTvNavHost()
                }
            }
        }
    }
}
