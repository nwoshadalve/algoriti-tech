/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.shell.application

import androidx.compose.ui.graphics.ImageBitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapLatest
import kotlinx.coroutines.flow.stateIn
import tech.algoriti.algoritiq_tv.core.network.TabletAddress
import tech.algoriti.algoritiq_tv.core.network.TabletAddressStore
import tech.algoriti.algoritiq_tv.features.display.data.DoctorPhotoLoader
import tech.algoriti.algoritiq_tv.features.display.presentation.DisplayBoardState
import tech.algoriti.algoritiq_tv.features.sync.domain.LiveSessionRepository
import tech.algoriti.algoritiq_tv.features.sync.domain.TestScreenState

data class TvShellUiState(
    val showMain: Boolean = false,
    val display: DisplayBoardState = DisplayBoardState(connected = false),
    val doctorPhoto: ImageBitmap? = null,
    val testScreen: TestScreenState? = null,
)

@OptIn(ExperimentalCoroutinesApi::class)
@HiltViewModel
class TvShellViewModel
    @Inject
    constructor(
        liveSession: LiveSessionRepository,
        photoLoader: DoctorPhotoLoader,
        private val tabletAddress: TabletAddressStore,
        private val connection: TvConnection,
    ) : ViewModel() {
        /** The tablet address typed on this TV, if any. */
        fun savedAddress(): String? = tabletAddress.saved()

        /** Saves what was typed and links again at once. False when it is not an address. */
        fun saveAddress(typed: String): Boolean {
            val address = TabletAddress.parse(typed) ?: return false
            tabletAddress.save(address)
            connection.reconnectNow()
            return true
        }

        // Looked up again whenever the photo changes or the link comes back, never while it is down.
        private val doctorPhoto: StateFlow<ImageBitmap?> =
            liveSession.display
                .filter { it.connected }
                .map { Triple(it.chamberId, it.photoPath, it.photoVersion) }
                .distinctUntilChanged()
                .mapLatest { (_, path, _) -> if (path.isBlank()) null else photoLoader.load(path) }
                .stateIn(viewModelScope, SharingStarted.Eagerly, null)

        val uiState: StateFlow<TvShellUiState> =
            combine(
                liveSession.reachedMain,
                liveSession.display,
                doctorPhoto,
                liveSession.testScreen,
            ) { reachedMain, display, photo, testScreen ->
                TvShellUiState(
                    showMain = reachedMain,
                    display = display,
                    doctorPhoto = photo,
                    testScreen = testScreen,
                )
            }.stateIn(viewModelScope, SharingStarted.Eagerly, TvShellUiState())
    }
