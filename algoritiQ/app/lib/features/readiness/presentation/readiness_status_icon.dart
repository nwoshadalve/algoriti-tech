// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../domain/readiness_item.dart';

/// Status glyph for a readiness row — filled chips read better than lone
/// [Icons.check_circle_rounded] on the light theme.
class ReadinessStatusIcon extends StatelessWidget {
  const ReadinessStatusIcon({super.key, required this.state});

  final ReadinessState state;

  static const _boxSize = 22.0;
  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (background, foreground, icon) = switch (state) {
      ReadinessState.done => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        Icons.check_rounded,
      ),
      ReadinessState.needed => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        Icons.priority_high_rounded,
      ),
      ReadinessState.unconfirmed => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        Icons.help_outline_rounded,
      ),
    };

    return SizedBox(
      width: _boxSize,
      height: _boxSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(_boxSize / 2),
        ),
        child: Icon(icon, size: _iconSize, color: foreground),
      ),
    );
  }
}
