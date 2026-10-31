// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/photo_store.dart';
import 'doctor_avatar.dart';

enum _Choice { gallery, camera, remove }

/// Round photo with a small camera badge; tap it to add or change the photo.
/// A sheet offers gallery, camera and (when there is a photo) remove. The
/// caller does the actual pick.
///
/// [compact] shrinks the picture, for short screens.
class DoctorPhotoField extends StatelessWidget {
  const DoctorPhotoField({
    super.key,
    required this.photoPath,
    required this.enabled,
    required this.onPick,
    required this.onRemove,
    this.compact = false,
  });

  /// Tap target in tests and automation.
  static const tapKey = ValueKey('doctor-photo');

  final String? photoPath;
  final bool enabled;
  final ValueChanged<PhotoSource> onPick;
  final VoidCallback onRemove;
  final bool compact;

  Future<void> _choose(BuildContext context) async {
    final choice = await showModalBottomSheet<_Choice>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ChoiceSheet(hasPhoto: photoPath != null),
    );
    switch (choice) {
      case _Choice.gallery:
        onPick(PhotoSource.gallery);
      case _Choice.camera:
        onPick(PhotoSource.camera);
      case _Choice.remove:
        onRemove();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final size = compact ? 56.0 : 72.0;

    return Semantics(
      button: true,
      enabled: enabled,
      label: photoPath != null ? l10n.changePhotoButton : l10n.addPhotoButton,
      excludeSemantics: true,
      child: InkWell(
        key: tapKey,
        borderRadius: BorderRadius.circular(Radii.field),
        onTap: enabled ? () => _choose(context) : null,
        child: Row(
          children: [
            _AvatarWithBadge(photoPath: photoPath, size: size),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                l10n.photoLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The photo with a small camera badge at its bottom-right corner.
class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({required this.photoPath, required this.size});

  final String? photoPath;
  final double size;

  static const _badge = 28.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        DoctorAvatar(photoPath: photoPath, size: size),
        Positioned(
          right: -Spacing.xs,
          bottom: -Spacing.xs,
          child: Container(
            width: _badge,
            height: _badge,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              // A ring in the card colour separates the badge from the photo.
              border: Border.all(color: scheme.surface, width: 2),
            ),
            child: Icon(
              Icons.photo_camera_rounded,
              size: 16,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceSheet extends StatelessWidget {
  const _ChoiceSheet({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.photoFromGallery),
            onTap: () => Navigator.of(context).pop(_Choice.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.photoFromCamera),
            onTap: () => Navigator.of(context).pop(_Choice.camera),
          ),
          if (hasPhoto)
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.removePhotoButton),
              onTap: () => Navigator.of(context).pop(_Choice.remove),
            ),
        ],
      ),
    );
  }
}
