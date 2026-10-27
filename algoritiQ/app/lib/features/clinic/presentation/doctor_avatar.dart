import 'dart:io';

import 'package:flutter/material.dart';

/// Round doctor photo, or a neutral person icon when there is none.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({super.key, required this.photoPath, this.size = 96});

  final String? photoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = photoPath;
    final placeholder = Icon(
      Icons.person_outline_rounded,
      size: size * 0.5,
      color: scheme.onSurfaceVariant,
    );
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: path == null
            ? placeholder
            : Image.file(
                File(path),
                width: size,
                height: size,
                fit: BoxFit.cover,
                // A missing or unreadable file falls back to the icon.
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}
