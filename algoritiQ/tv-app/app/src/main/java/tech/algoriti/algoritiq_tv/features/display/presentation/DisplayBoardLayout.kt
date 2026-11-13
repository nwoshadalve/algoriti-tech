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
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.layout
import androidx.compose.ui.unit.Constraints
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
import java.util.TimeZone
import kotlinx.coroutines.delay
import tech.algoriti.algoritiq_tv.R

private val Navy = Color(0xFF0B1F3A)
private val NavyLift = Color(0xFF16345F)
private val Accent = Color(0xFFEA580C)
private val Page = Color(0xFFF1F5F9)
private val Line = Color(0xFFE2E8F0)
private val Muted = Color(0xFF475569)
private val Faint = Color(0xFF64748B)

/** How long someone has waited, as a colour: calm, getting long, long. The words always say it too. */
private val WaitShort = Color(0xFF16A34A)
private val WaitMedium = Color(0xFFD97706)
private val WaitLong = Color(0xFFDC2626)

/** Under 10 minutes calm, up to 30 minutes getting long, longer than that long. */
internal fun waitColor(seconds: Int): Color {
    val minutes = seconds / 60
    return when {
        minutes < 10 -> WaitShort
        minutes < 30 -> WaitMedium
        else -> WaitLong
    }
}

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
        IdentityPanel(state = state, photo = doctorPhoto, modifier = Modifier.width(312.dp).fillMaxHeight())
        Column(
            modifier = Modifier.weight(1f).fillMaxHeight().alpha(dim),
            verticalArrangement = Arrangement.spacedBy(18.dp),
        ) {
            CalledCard(state = state, modifier = Modifier.weight(0.92f).fillMaxWidth())
            WaitingPanel(state = state, modifier = Modifier.weight(1.2f).fillMaxWidth())
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
    Box(
        modifier =
            modifier
                .clip(shape)
                .background(Color.White)
                .border(1.dp, Line, shape)
                .padding(horizontal = 24.dp, vertical = 20.dp),
    ) {
    // Nothing is cut short: if the doctor's details are long, the whole block shrinks to fit.
    Column(
        modifier = Modifier.fillMaxSize().shrinkToFitHeight(),
        verticalArrangement = Arrangement.Center,
    ) {
        // No photo, no picture box: the details use the whole card.
        if (photo != null) {
            DoctorPhoto(photo, modifier = Modifier.size(128.dp).align(Alignment.CenterHorizontally))
            Spacer(Modifier.height(16.dp))
        }
        Text(
            text = state.doctorNameBn,
            color = Navy,
            fontSize = 25.sp,
            fontWeight = FontWeight.ExtraBold,
        )
        if (state.doctorDegrees.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = state.doctorDegrees,
                color = Muted,
                fontSize = 13.sp,
                fontWeight = FontWeight.SemiBold,
            )
        }
        if (state.doctorDesignation.isNotBlank()) {
            Spacer(Modifier.height(6.dp))
            Text(
                text = state.doctorDesignation,
                color = Navy,
                fontSize = 15.sp,
                fontWeight = FontWeight.SemiBold,
            )
        }
        if (state.doctorSpecialty.isNotBlank()) {
            Text(text = state.doctorSpecialty, color = Muted, fontSize = 14.sp)
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
}

/**
 * Lays the content out at its full height and, if that is taller than the space, scales the whole
 * block down so every line is shown (the screen cannot be scrolled from across the room).
 */
private fun Modifier.shrinkToFit(): Modifier =
    layout { measurable, constraints ->
        val placeable = measurable.measure(Constraints())
        val scale =
            minOf(
                1f,
                if (placeable.width > 0) constraints.maxWidth.toFloat() / placeable.width else 1f,
                if (placeable.height > 0) constraints.maxHeight.toFloat() / placeable.height else 1f,
            )
        val width = (placeable.width * scale).toInt()
        val height = (placeable.height * scale).toInt()
        layout(width, height) {
            // Scaled about the left edge and the middle, so lift it to sit in the middle of the space.
            placeable.placeWithLayer(0, (height - placeable.height) / 2) {
                transformOrigin = TransformOrigin(0f, 0.5f)
                scaleX = scale
                scaleY = scale
            }
        }
    }

private fun Modifier.shrinkToFitHeight(): Modifier =
    layout { measurable, constraints ->
        val placeable = measurable.measure(constraints.copy(minHeight = 0, maxHeight = Constraints.Infinity))
        val available = constraints.maxHeight
        val scale = if (placeable.height > available && placeable.height > 0) available.toFloat() / placeable.height else 1f
        layout(placeable.width, minOf(placeable.height, available)) {
            // The block scales about its own centre, so lift it to sit in the middle of the space.
            val y = if (scale < 1f) (available - placeable.height) / 2 else 0
            placeable.placeWithLayer(0, y) {
                transformOrigin = TransformOrigin(0f, 0.5f)
                scaleX = scale
                scaleY = scale
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
    photo: ImageBitmap,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(22.dp)
    Box(
        modifier = modifier.clip(shape).background(Page).border(3.dp, Line, shape),
        contentAlignment = Alignment.Center,
    ) {
        Image(
            bitmap = photo,
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize(),
        )
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
    val anyCalled = state.calls.isNotEmpty()
    val waiting = state.queueTypes.sumOf { it.waitingSerials.size + it.hiddenCount }
    // A new call flashes the card from navy to orange and back, so it is noticed from across the room.
    var flash by remember { mutableStateOf(false) }
    LaunchedEffect(called, state.callPulse) {
        if (called != null) {
            flash = true
            delay(1600)
            flash = false
        }
    }
    val top by animateColorAsState(if (flash) Accent else NavyLift, tween(450), label = "flashTop")
    val shape = RoundedCornerShape(28.dp)
    Column(
        modifier =
            modifier
                .clip(shape)
                .background(Brush.verticalGradient(listOf(top, Navy)))
                .padding(horizontal = 32.dp, vertical = 22.dp),
    ) {
        // The header takes its own height; the number is centred in the space left below it, so the
        // time and date never crowd it.
        Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.Top) {
            Box(Modifier.height(36.dp), contentAlignment = Alignment.Center) { PulseDot(active = anyCalled) }
            Spacer(Modifier.width(10.dp))
            Box(Modifier.height(36.dp), contentAlignment = Alignment.Center) {
                Text(
                    text = stringResource(if (!anyCalled) R.string.display_please_wait else R.string.display_now_serving),
                    color = Color.White.copy(alpha = 0.85f),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.SemiBold,
                )
            }
            Spacer(Modifier.weight(1f))
            Clock()
        }
        Box(modifier = Modifier.weight(1f).fillMaxWidth(), contentAlignment = Alignment.Center) {
            CalledNumber(calls = state.calls, newest = called, pulse = state.callPulse, waiting = waiting)
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun CalledNumber(
    calls: List<CalledToken>,
    newest: Int?,
    pulse: Int,
    waiting: Int,
) {
    Box {
        AnimatedContent(
            // The pulse is part of the target, so a recall of the same number animates in again.
            targetState = Triple(calls, newest, pulse),
            transitionSpec = {
                (
                    slideInVertically(spring(stiffness = Spring.StiffnessMediumLow)) { it / 2 } +
                        fadeIn(tween(350)) +
                        scaleIn(spring(dampingRatio = Spring.DampingRatioMediumBouncy), initialScale = 0.8f)
                ) togetherWith (slideOutVertically(tween(300)) { -it / 2 } + fadeOut(tween(250)))
            },
            label = "called",
        ) { (shown, latest, _) ->
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                if (shown.isEmpty()) {
                    // Nobody is called: say whether people are waiting, never that nothing has happened.
                    Text(
                        text = stringResource(if (waiting > 0) R.string.display_soon else R.string.display_nobody),
                        color = Color.White,
                        fontSize = 40.sp,
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center,
                    )
                } else {
                    CalledTiles(shown, latest)
                }
            }
        }
    }
}

/**
 * The tokens being called, one tile per queue. A lone call is as big as the card allows; several
 * share the width, each with its queue name, and the newest is lit.
 */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun CalledTiles(
    calls: List<CalledToken>,
    newest: Int?,
) {
    val alone = calls.size == 1
    val numberSize = if (alone) 120.sp else if (calls.size == 2) 84.sp else 64.sp
    Row(modifier = Modifier.shrinkToFit(), horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        calls.forEach { call ->
            // Outlined in orange until the call has been announced.
            val lit = !call.announced
            val framed = !alone || !call.announced
            val shape = RoundedCornerShape(22.dp)
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier =
                    if (!framed) {
                        Modifier
                    } else {
                        Modifier
                            .clip(shape)
                            .background(Color.White.copy(alpha = if (lit) 0.16f else 0.07f))
                            .border(if (lit) 3.dp else 1.5.dp, if (lit) Accent else Color.White.copy(alpha = 0.24f), shape)
                            .padding(horizontal = 22.dp, vertical = 10.dp)
                    },
            ) {
                if (!alone && call.queueLabelBn.isNotBlank()) {
                    Text(
                        text = call.queueLabelBn,
                        color = Color.White.copy(alpha = 0.9f),
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                    )
                }
                Text(
                    text = bnDigits(call.serial.toString()),
                    color = Color.White,
                    fontSize = numberSize,
                    fontWeight = FontWeight.ExtraBold,
                )
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

private val BangladeshTime: TimeZone = TimeZone.getTimeZone("Asia/Dhaka")

/** The time and date in Bangladesh, whatever the TV's own timezone is set to, in Bengali. */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun Clock() {
    val format = remember { SimpleDateFormat("hh:mm", Locale.US).apply { timeZone = BangladeshTime } }
    val dateFormat =
        remember { SimpleDateFormat("EEEE, d MMMM yyyy", Locale("bn", "BD")).apply { timeZone = BangladeshTime } }
    var now by remember { mutableStateOf(Date()) }
    LaunchedEffect(Unit) {
        while (true) {
            now = Date()
            delay(60_000L - System.currentTimeMillis() % 60_000L)
        }
    }
    Column(horizontalAlignment = Alignment.End) {
        Text(
            text = bnDigits(format.format(now)),
            color = Color.White,
            fontSize = 30.sp,
            fontWeight = FontWeight.Bold,
        )
        Text(
            text = bnDigits(dateFormat.format(now)),
            color = Color.White.copy(alpha = 0.85f),
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold,
        )
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun WaitingPanel(
    state: DisplayBoardState,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(28.dp)
    // The waiting times count on by themselves between updates from the tablet.
    var nowMs by remember { mutableStateOf(System.currentTimeMillis()) }
    LaunchedEffect(Unit) {
        while (true) {
            delay(15_000L)
            nowMs = System.currentTimeMillis()
        }
    }
    val people = state.queueTypes.sumOf { it.waitingSerials.size + it.hiddenCount }
    Column(
        modifier =
            modifier
                .clip(shape)
                .background(Color.White)
                .border(1.dp, Line, shape)
                .padding(start = 16.dp, top = 14.dp, end = 16.dp, bottom = 16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            Text(
                text = stringResource(R.string.display_waiting_heading),
                color = Navy,
                fontSize = 24.sp,
                fontWeight = FontWeight.ExtraBold,
            )
            Spacer(modifier = Modifier.weight(1f))
            if (people > 0) {
                Text(
                    text = bnDigits(stringResource(R.string.display_total_waiting, people)),
                    color = Accent,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.ExtraBold,
                )
            }
        }
        Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            state.queueTypes.forEach { type ->
                QueueRow(type, sinceMs = nowMs - state.receivedAtMs, modifier = Modifier.weight(1f))
            }
        }
    }
}

@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun QueueRow(
    type: QueueTypeBoard,
    sinceMs: Long,
    modifier: Modifier,
) {
    val shape = RoundedCornerShape(18.dp)
    Row(
        modifier = modifier.fillMaxWidth().clip(shape).background(Page).padding(horizontal = 16.dp, vertical = 6.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
    ) {
        Text(
            text = type.labelBn,
            color = Navy,
            fontSize = 19.sp,
            fontWeight = FontWeight.ExtraBold,
            modifier = Modifier.width(84.dp),
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        // Never bigger than the row: the chips shrink together if they would not fit.
        Row(modifier = Modifier.weight(1f).shrinkToFit(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            if (type.waitingSerials.isEmpty()) {
                Text(text = "—", color = Faint, fontSize = 24.sp, fontWeight = FontWeight.Bold)
            }
            // A chip is a place in the line. When someone is called the next serial slides up into it.
            type.waitingSerials.forEachIndexed { place, serial ->
                val waited = type.waitedSeconds.getOrElse(place) { 0 } + (sinceMs / 1000L).toInt().coerceAtLeast(0)
                SerialChip(serial, waitedSeconds = waited, next = place == 0)
            }
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
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                )
            }
        }
    }
}

/** How long someone has waited: `এইমাত্র`, `৫ মিনিট`, `১ ঘ ১০ মি`. */
@Composable
private fun waitedText(seconds: Int): String {
    val minutes = seconds / 60
    return when {
        minutes < 1 -> stringResource(R.string.display_waited_now)
        minutes < 60 -> bnDigits(stringResource(R.string.display_waited_minutes, minutes))
        else -> bnDigits(stringResource(R.string.display_waited_hours, minutes / 60, minutes % 60))
    }
}

/**
 * The next in line is filled, so the eye lands on it first. Under each serial is how long it
 * has waited, with a dot that goes from green to amber to red as the wait grows.
 */
@OptIn(ExperimentalTvMaterial3Api::class)
@Composable
private fun SerialChip(
    serial: Int,
    waitedSeconds: Int,
    next: Boolean,
) {
    val shape = RoundedCornerShape(16.dp)
    val fill by animateColorAsState(if (next) Navy else Color.White, tween(400), label = "chipFill")
    Box(contentAlignment = Alignment.TopCenter) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier =
                Modifier
                    .clip(shape)
                    .background(fill)
                    .border(1.5.dp, if (next) Navy else Line, shape)
                    .padding(horizontal = 11.dp, vertical = 5.dp),
        ) {
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
                    fontSize = 30.sp,
                    fontWeight = FontWeight.ExtraBold,
                    textAlign = TextAlign.Center,
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Box(Modifier.size(10.dp).clip(CircleShape).background(waitColor(waitedSeconds)))
                Text(
                    text = waitedText(waitedSeconds),
                    color = if (next) Color.White else Navy,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 1,
                )
            }
        }
    }
}
