import 'package:flutter/material.dart';

/// Compact action for one readiness row — matches [IconButton.outlined] elsewhere.
class ReadinessActionButton extends StatelessWidget {
  const ReadinessActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
    );
  }
}
