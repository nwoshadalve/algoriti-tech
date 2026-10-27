import 'package:flutter/material.dart';

/// AlgoritiQ loading indicator: three dots light up in turn, like tokens
/// being called one after another.
///
/// Reuse this for every wait (buttons, screens, lists) instead of
/// [CircularProgressIndicator]. On plain surfaces the lit dot is coral and
/// idle dots use the theme's outline colour, so it works in light and dark.
/// Inside a coloured control pass [color] and [idleColor] (see
/// `LoadingButton`).
///
/// Honours the system "remove animations" setting: the dots hold still with
/// the middle one lit.
class BrandLoader extends StatefulWidget {
  const BrandLoader({
    super.key,
    this.dotSize = 8,
    this.color,
    this.idleColor,
    this.semanticLabel,
  });

  /// Diameter of one dot. The loader is about five dots wide.
  final double dotSize;

  /// Colour of the lit dot. Defaults to the theme's coral (tertiary).
  final Color? color;

  /// Colour of the idle dots. Defaults to the theme's outline variant.
  final Color? idleColor;

  /// Announced to screen readers; pass the localized "Loading…" text.
  final String? semanticLabel;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  /// Progress at which the middle dot is fully lit (static pose): one third
  /// of a cycle late, plus its rise time.
  static const _restingProgress = 1 / 3 + 0.2;

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
    final scheme = Theme.of(context).colorScheme;
    final d = widget.dotSize;
    final loader = ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size(d * _DotsPainter.widthInDots, d * 1.5),
            painter: _DotsPainter(
              progress: _controller.value,
              lit: widget.color ?? scheme.tertiary,
              idle: widget.idleColor ?? scheme.outlineVariant,
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

class _DotsPainter extends CustomPainter {
  const _DotsPainter({
    required this.progress,
    required this.lit,
    required this.idle,
  });

  final double progress;
  final Color lit;
  final Color idle;

  static const _dots = 3;
  static const _gapInDots = 0.8;
  static const widthInDots = _dots + (_dots - 1) * _gapInDots;

  /// Share of the cycle a dot spends lighting up, then fading.
  static const _rise = 0.2;
  static const _fall = 0.4;

  @override
  void paint(Canvas canvas, Size size) {
    final d = size.width / widthInDots;
    final baseline = size.height - d / 2;

    for (var i = 0; i < _dots; i++) {
      // Each dot is called a third of a cycle after the previous one.
      final phase = (progress - i / _dots) % 1;
      final glow = Curves.easeInOut.transform(_intensity(phase));
      final center = Offset(
        d / 2 + i * d * (1 + _gapInDots),
        baseline - glow * d * 0.4,
      );
      // lerp only returns null when both colours are null; neither is.
      final color = Color.lerp(idle, lit, glow)!;
      canvas.drawCircle(center, d / 2, Paint()..color = color);
    }
  }

  double _intensity(double phase) {
    if (phase < _rise) return phase / _rise;
    if (phase < _rise + _fall) return 1 - (phase - _rise) / _fall;
    return 0;
  }

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.progress != progress || old.lit != lit || old.idle != idle;
}
