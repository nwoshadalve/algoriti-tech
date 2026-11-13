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
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.Button
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import kotlinx.coroutines.delay
import tech.algoriti.algoritiq_tv.R
import tech.algoriti.algoritiq_tv.core.ui.BrandLoader

/** How long the TV waits for the tablet before it offers a way to type the tablet's address. */
private const val ADDRESS_OFFER_AFTER_MS = 12_000L

/**
 * Shown until the tablet answers. Normally nothing technical is on screen. If the tablet is still
 * not found after a while (a network that does not pass its name along), a field appears to type
 * its address.
 */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun ConnectingScreen(
    savedAddress: String? = null,
    onSaveAddress: (String) -> Boolean = { false },
) {
    val scheme = MaterialTheme.colorScheme
    var offerAddress by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) {
        delay(ADDRESS_OFFER_AFTER_MS)
        offerAddress = true
    }
    Column(
        modifier =
            Modifier
                .fillMaxSize()
                .background(scheme.surface)
                .padding(48.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Text(
            text = stringResource(R.string.connecting_title),
            color = scheme.onSurface,
            fontSize = 36.sp,
            fontWeight = FontWeight.Bold,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = stringResource(R.string.connecting_please_wait),
            color = scheme.onSurfaceVariant,
            fontSize = 22.sp,
            textAlign = TextAlign.Center,
        )
        Spacer(modifier = Modifier.height(40.dp))
        BrandLoader(
            dotSize = 22.dp,
            lit = scheme.tertiary,
            idle = scheme.outlineVariant,
        )
        if (offerAddress) {
            Spacer(modifier = Modifier.height(48.dp))
            AddressEntry(savedAddress = savedAddress, onSave = onSaveAddress)
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun AddressEntry(
    savedAddress: String?,
    onSave: (String) -> Boolean,
) {
    val scheme = MaterialTheme.colorScheme
    var typed by remember { mutableStateOf(savedAddress.orEmpty()) }
    var invalid by remember { mutableStateOf(false) }
    fun submit() {
        invalid = !onSave(typed)
    }
    Text(
        text = stringResource(R.string.connecting_address_hint),
        color = scheme.onSurfaceVariant,
        fontSize = 20.sp,
        textAlign = TextAlign.Center,
    )
    Spacer(modifier = Modifier.height(16.dp))
    OutlinedTextField(
        value = typed,
        onValueChange = {
            typed = it
            invalid = false
        },
        label = { androidx.compose.material3.Text(stringResource(R.string.connecting_address_label)) },
        singleLine = true,
        isError = invalid,
        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Done),
        keyboardActions = KeyboardActions(onDone = { submit() }),
        modifier = Modifier.width(360.dp),
    )
    if (invalid) {
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = stringResource(R.string.connecting_address_invalid),
            color = scheme.error,
            fontSize = 18.sp,
            textAlign = TextAlign.Center,
        )
    }
    Spacer(modifier = Modifier.height(16.dp))
    Button(onClick = { submit() }) {
        Text(text = stringResource(R.string.connecting_address_connect), fontSize = 20.sp)
    }
}
