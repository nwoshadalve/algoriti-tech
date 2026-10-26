import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/brand_colors.dart';

/// AlgoritiQ logo, drawn from `branding/logo/algoritiq/svg`.
///
/// Picks the normal (navy) or reversed (white) variant from the current
/// theme brightness. [BrandLogo.wordmark] adds the name; [BrandLogo.symbol]
/// is the three-bar mark only. [height] is the logical height of the logo.
class BrandLogo extends StatelessWidget {
  const BrandLogo.wordmark({super.key, this.height = 64}) : _withName = true;

  const BrandLogo.symbol({super.key, this.height = 64}) : _withName = false;

  final double height;
  final bool _withName;

  static const _symbolSize = Size(90, 100);
  static const _wordmarkSize = Size(370, 100);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? BrandColors.white : BrandColors.navy;
    final size = _withName ? _wordmarkSize : _symbolSize;

    return Semantics(
      label: 'AlgoritiQ',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          width: height * size.width / size.height,
          child: FittedBox(
            child: CustomPaint(
              size: size,
              painter: _LogoPainter(ink: ink, withName: _withName),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.ink, required this.withName});

  final Color ink;
  final bool withName;

  @override
  void paint(Canvas canvas, Size size) {
    _bar(canvas, const Rect.fromLTWH(8, 14, 56, 20), ink);
    _bar(canvas, const Rect.fromLTWH(26, 40, 56, 20), BrandColors.coral);
    _bar(canvas, const Rect.fromLTWH(8, 66, 56, 20), ink);
    if (withName) _name(canvas);
  }

  void _bar(Canvas canvas, Rect rect, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = color,
    );
  }

  /// Name at x=100, baseline y=66, 46 px bold, tracking -1.5 (as in the SVG).
  void _name(Canvas canvas) {
    TextStyle style(Color color) => TextStyle(
      fontFamily: brandFontFamily,
      fontSize: 46,
      fontWeight: FontWeight.w700,
      fontVariations: const [FontVariation('wght', 700)],
      letterSpacing: -1.5,
      color: color,
    );

    final painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: style(ink),
        children: [
          const TextSpan(text: 'Algoriti'),
          TextSpan(text: 'Q', style: style(BrandColors.coral)),
        ],
      ),
    )..layout();

    final baseline = painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    painter.paint(canvas, Offset(100, 66 - baseline));
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.ink != ink || old.withName != withName;
}
