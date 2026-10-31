// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/brand_colors.dart';

enum HealthStatus { ok, pending, error }

/// Coloured dot plus status text (connection / server health).
class HealthStatusRow extends StatelessWidget {
  const HealthStatusRow({
    super.key,
    required this.status,
    required this.message,
  });

  final HealthStatus status;
  final String message;

  Color _dotColor(ColorScheme scheme) => switch (status) {
    HealthStatus.ok => const Color(0xFF10B981),
    HealthStatus.pending => scheme.onSurface.withValues(alpha: 0.35),
    HealthStatus.error => BrandColors.coral,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dot = _dotColor(theme.colorScheme);

    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: Spacing.sm + Spacing.xs),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
