/*
 * Copyright (c) Algoriti Technologies Ltd.
 */
package tech.algoriti.algoritiq_tv.features.display.presentation

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.Text
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlinx.coroutines.delay
import tech.algoriti.algoritiq_tv.R

private val Navy = Color(0xFF0B1F3A)
private val NavyLift = Color(0xFF16345F)
private val Accent = Color(0xFFEA580C)
private val AccentSoft = Color(0xFFFFEDD5)
private val Page = Color(0xFFF1F5F9)
private val Line = Color(0xFFE2E8F0)
private val Muted = Color(0xFF475569)
private val Faint = Color(0xFF64748B)

/** Western digits to Bengali ones: the waiting room reads Bengali numerals. */
internal fun bnDigits(text: String): String = text.map { if (it in '0'..'9') "০১২৩৪৫৬৭৮৯"[it - '0'] else it }.joinToString("")

/**
 * The waiting-room board. The doctor and chamber on the left; on the right the patient being called
 * as a large card, and below it who is waiting. Everything on it comes from the tablet. When the
 * tablet's session changes, the numbers move rather than jump.
 */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
fun DisplayBoardLayout(
    state: DisplayBoardState,
    doctorPhoto: ImageBitmap? = null,
    footerActions: @Composable () -> Unit = {},
) {
    // Without a link the numbers may be old: they fade, with no words on the screen.
    val dim by animateFloatAsState(if (state.connected) 1f else 0.5f, tween(600), label = "dim")
    Row(
        modifier =
            Modifier
                .fillMaxSize()
                .background(Page)
                .padding(horizontal = 36.dp, vertical = 28.dp),
        horizontalArrangement = Arrangement.spacedBy(24.dp),
    ) {
        IdentityPanel(state = state, photo = doctorPhoto, modifier = Modifier.width(340.dp).fillMaxHeight())
        Column(
            modifier = Modifier.weight(1f).fillMaxHeight().alpha(dim),
            verticalArrangement = Arrangement.spacedBy(20.dp),
        ) {
            CalledCard(state = state, modifier = Modifier.weight(1.15f).fillMaxWidth())
            WaitingPanel(state = state, modifier = Modifier.weight(1f).fillMaxWidth())
            footerActions()
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun IdentityPanel(
    state: DisplayBoardState,
    photo: ImageBitmap?,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(28.dp)
    Column(
        modifier =
            modifier
                .clip(shape)
                .background(Color.White)
                .border(1.dp, Line, shape)
                .padding(horizontal = 24.dp, vertical = 20.dp),
        verticalArrangement = Arrangement.Center,
    ) {
        DoctorPhoto(photo, state.doctorNameBn, modifier = Modifier.size(128.dp).align(Alignment.CenterHorizontally))
        Spacer(Modifier.height(16.dp))
        Text(
            text = state.doctorNameBn,
            color = Navy,
            fontSize = 25.sp,
            fontWeight = FontWeight.ExtraBold,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        if (state.doctorDegrees.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = state.doctorDegrees,
                color = Muted,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = 3,
                overflow = TextOverflow.Ellipsis,
            )
        }
        if (state.doctorDesignation.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = state.doctorDesignation,
                color = Navy,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
        }
        if (state.doctorSpecialty.isNotBlank()) {
            Text(text = state.doctorSpecialty, color = Muted, fontSize = 14.sp, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
        SubLine(state.doctorWorkplace)
        if (state.doctorRegistration.isNotBlank()) {
            SubLine(stringResource(R.string.display_registration, bnDigits(state.doctorRegistration)))
        }
        Spacer(Modifier.height(12.dp))
        Box(Modifier.fillMaxWidth().height(1.dp).background(Line))
        Spacer(Modifier.height(12.dp))
        Text(
            text = state.chamberNameBn,
            color = Navy,
            fontSize = 19.sp,
            fontWeight = FontWeight.ExtraBold,
            maxLines = 3,
            overflow = TextOverflow.Ellipsis,
        )
        SubLine(state.chamberLocation)
        if (state.chamberPhone.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = bnDigits(formatPhone(state.chamberPhone)),
                color = Accent,
                fontSize = 17.sp,
                fontWeight = FontWeight.Bold,
            )
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun SubLine(text: String) {
    if (text.isBlank()) return
    Text(text = text, color = Faint, fontSize = 13.sp, maxLines = 2, overflow = TextOverflow.Ellipsis)
}

/** `01711000111` as `01711-000111`; anything else as it is. */
internal fun formatPhone(phone: String): String {
    val digits = phone.filter { it.isDigit() }
    return if (digits.length == 11 && digits.startsWith("01")) "${digits.take(5)}-${digits.drop(5)}" else phone
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun DoctorPhoto(
    photo: ImageBitmap?,
    name: String,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(22.dp)
    Box(
        modifier = modifier.clip(shape).background(Page).border(3.dp, Line, shape),
        contentAlignment = Alignment.Center,
    ) {
        // The photo arrives after the first screen; it settles in rather than popping.
        AnimatedContent(
            targetState = photo,
            transitionSpec = { fadeIn(tween(500)) togetherWith fadeOut(tween(300)) },
            label = "photo",
        ) { image ->
            if (image != null) {
                Image(
                    bitmap = image,
                    contentDescription = null,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize(),
                )
            } else {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text(text = name.trim().take(1), color = Navy, fontSize = 48.sp, fontWeight = FontWeight.ExtraBold)
                }
            }
        }
    }
}

/** The patient being called: the loudest thing on the screen. */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun CalledCard(
    state: DisplayBoardState,
    modifier: Modifier,
) {
    val called = state.calledSerial
    // A new call flashes the card from navy to orange and back, so it is noticed from across the room.
    var flash by remember { mutableStateOf(false) }
    LaunchedEffect(called) {
        if (called != null) {
            flash = true
            delay(1600)
            flash = false
        }
    }
    val top by animateColorAsState(if (flash) Accent else NavyLift, tween(450), label = "flashTop")
    val shape = RoundedCornerShape(28.dp)
    Box(
        modifier =
            modifier
                .clip(shape)
                .background(Brush.verticalGradient(listOf(top, Navy)))
                .padding(horizontal = 32.dp, vertical = 22.dp),
    ) {
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            PulseDot(active = called != null)
            Spacer(Modifier.width(10.dp))
            Text(
                text = stringResource(if (called == null) R.string.display_please_wait else R.string.display_now_serving),
                color = Color.White.copy(alpha = 0.85f),
                fontSize = 22.sp,
                fontWeight = FontWeight.SemiBold,
            )
            Spacer(Modifier.weight(1f))
            Clock()
        }
        AnimatedContent(
            targetState = called to state.calledTypeLabelBn,
            modifier = Modifier.align(Alignment.Center),
            transitionSpec = {
                (
                    slideInVertically(spring(stiffness = Spring.StiffnessMediumLow)) { it / 2 } +
                        fadeIn(tween(350)) +
                        scaleIn(spring(dampingRatio = Spring.DampingRatioMediumBouncy), initialScale = 0.8f)
                ) togetherWith (slideOutVertically(tween(300)) { -it / 2 } + fadeOut(tween(250)))
            },
            label = "called",
        ) { (serial, type) ->
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (serial == null) {
                    Text(
                        text = stringResource(R.string.display_idle_hint),
                        color = Color.White,
                        fontSize = 34.sp,
                        fontWeight = FontWeight.SemiBold,
                        textAlign = TextAlign.Center,
                    )
                } else {
                    Text(
                        text = bnDigits(serial.toString()),
                        color = Color.White,
                        fontSize = 120.sp,
                        fontWeight = FontWeight.ExtraBold,
                    )
                    type?.let {
                        Text(
                            text = it,
                            color = Color(0xFF9A3412),
                            fontSize = 24.sp,
                            fontWeight = FontWeight.ExtraBold,
                            modifier =
                                Modifier
                                    .padding(top = 6.dp)
                                    .clip(RoundedCornerShape(50))
                                    .background(AccentSoft)
                                    .padding(horizontal = 30.dp, vertical = 8.dp),
                        )
                    }
                }
            }
        }
    }
}

/** A dot that breathes while someone is being called. */
@Composable
private fun PulseDot(active: Boolean) {
    val pulse = rememberInfiniteTransition(label = "pulse")
    val grow by pulse.animateFloat(
        initialValue = 0.8f,
        targetValue = 1.25f,
        animationSpec = infiniteRepeatable(tween(900), RepeatMode.Reverse),
        label = "grow",
    )
    Box(
        Modifier
            .size(14.dp)
            .scale(if (active) grow else 1f)
            .clip(CircleShape)
            .background(if (active) Accent else Color.White.copy(alpha = 0.4f)),
    )
}

/** The time, in Bengali digits, kept to the minute. */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun Clock() {
    val format = remember { SimpleDateFormat("hh:mm", Locale.US) }
    var now by remember { mutableStateOf(Date()) }
    LaunchedEffect(Unit) {
        while (true) {
            now = Date()
            delay(60_000L - System.currentTimeMillis() % 60_000L)
        }
    }
    Text(
        text = bnDigits(format.format(now)),
        color = Color.White,
        fontSize = 30.sp,
        fontWeight = FontWeight.Bold,
    )
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun WaitingPanel(
    state: DisplayBoardState,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(28.dp)
    Column(
        modifier = modifier.clip(shape).background(Color.White).border(1.dp, Line, shape).padding(18.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Text(
            text = stringResource(R.string.display_waiting_heading),
            color = Navy,
            fontSize = 22.sp,
            fontWeight = FontWeight.ExtraBold,
            modifier = Modifier.padding(start = 6.dp),
        )
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            state.queueTypes.forEach { type -> QueueRow(type, modifier = Modifier.weight(1f)) }
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun QueueRow(
    type: QueueTypeBoard,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(18.dp)
    Row(
        modifier = modifier.fillMaxWidth().clip(shape).background(Page).padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(
            text = type.labelBn,
            color = Navy,
            fontSize = 19.sp,
            fontWeight = FontWeight.ExtraBold,
            modifier = Modifier.width(104.dp),
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
        )
        Row(modifier = Modifier.weight(1f), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            if (type.waitingSerials.isEmpty()) {
                Text(text = "—", color = Faint, fontSize = 22.sp, fontWeight = FontWeight.Bold)
            }
            // A chip is a place in the line. When someone is called the next serial slides up into it.
            type.waitingSerials.forEachIndexed { place, serial -> SerialChip(serial, next = place == 0) }
        }
        AnimatedContent(
            targetState = type.hiddenCount,
            transitionSpec = { fadeIn(tween(300)) togetherWith fadeOut(tween(200)) },
            label = "more",
        ) { hidden ->
            if (hidden > 0) {
                Text(
                    text = bnDigits(stringResource(R.string.display_more_waiting, hidden)),
                    color = Faint,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                )
            }
        }
    }
}

/** The next in line is filled, so the eye lands on it first. */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun SerialChip(
    serial: Int,
    next: Boolean,
) {
    val shape = RoundedCornerShape(14.dp)
    val fill by animateColorAsState(if (next) Navy else Color.White, tween(400), label = "chipFill")
    AnimatedContent(
        targetState = serial,
        transitionSpec = {
            (slideInVertically(tween(350)) { it } + fadeIn(tween(350))) togetherWith
                (slideOutVertically(tween(250)) { -it } + fadeOut(tween(200)))
        },
        label = "chip",
    ) { value ->
        Text(
            text = bnDigits(value.toString()),
            color = if (next) Color.White else Navy,
            fontSize = 24.sp,
            fontWeight = FontWeight.ExtraBold,
            textAlign = TextAlign.Center,
            modifier =
                Modifier
                    .clip(shape)
                    .background(fill)
                    .border(1.dp, if (next) Navy else Line, shape)
                    .padding(horizontal = 12.dp, vertical = 8.dp),
        )
    }
}
