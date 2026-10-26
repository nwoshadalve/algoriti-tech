import 'dart:math' as math;

import 'package:flutter/material.dart';

/// AlgoritiQ loading indicator: the three logo bars take turns stepping out
/// of line, like a queue advancing.
///
/// Reuse this for every wait (buttons, screens, lists) instead of
/// [CircularProgressIndicator]. [color] defaults to the surrounding icon
/// colour, so inside a button it matches the label. Give [accentColor] to
/// tint the bar that is stepping out (coral on plain backgrounds).
///
/// Honours the system "remove animations" setting: the bars hold still with
/// the middle one forward, as in the logo.
class BrandLoader extends StatefulWidget {
  const BrandLoader({
    super.key,
    this.size = 24,
    this.color,
    this.accentColor,
    this.semanticLabel,
  });

  final double size;
  final Color? color;
  final Color? accentColor;

  /// Announced to screen readers; pass the localized "Loading…" text.
  final String? semanticLabel;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  /// Progress at which the middle bar is fully forward (static pose).
  static const _restingProgress = 0.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = _restingProgress;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color;
    final resolved = color ?? Theme.of(context).colorScheme.primary;
    final loader = ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _LoaderPainter(
              progress: _controller.value,
              color: resolved,
              accent: widget.accentColor ?? resolved,
            ),
          ),
        ),
      ),
    );
    final label = widget.semanticLabel;
    if (label == null) return loader;
    return Semantics(label: label, liveRegion: true, child: loader);
  }
}

class _LoaderPainter extends CustomPainter {
  const _LoaderPainter({
    required this.progress,
    required this.color,
    required this.accent,
  });

  final double progress;
  final Color color;
  final Color accent;

  static const _barCount = 3;
  static const _barHeight = 0.22;
  static const _barWidth = 0.72;
  static const _gap = 0.14;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width;
    final travel = unit * (1 - _barWidth);
    final top = (unit - unit * (_barCount * _barHeight + 2 * _gap)) / 2;

    for (var i = 0; i < _barCount; i++) {
      // Each bar owns one third of the cycle and eases out and back.
      final turn = (progress * _barCount - i).clamp(0.0, 1.0);
      final step = math.sin(math.pi * turn);
      final rect = Rect.fromLTWH(
        travel * step,
        top + i * unit * (_barHeight + _gap),
        unit * _barWidth,
        unit * _barHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(unit * 0.07)),
        Paint()..color = Color.lerp(color, accent, step)!,
      );
    }
  }

  @override
  bool shouldRepaint(_LoaderPainter old) =>
      old.progress != progress || old.color != color || old.accent != accent;
}
