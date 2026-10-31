// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../theme/app_radii.dart';

/// Opens the dashboard navigation drawer. Matches the web top bar menu control.
class DashboardNavMenuButton extends StatelessWidget {
  const DashboardNavMenuButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.expanded = false,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        expanded: expanded,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(Radii.field),
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.field),
              ),
              child: Icon(
                Icons.menu_rounded,
                size: 24,
                color: scheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
