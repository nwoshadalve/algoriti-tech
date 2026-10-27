import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/doctor.dart';
import 'doctor_avatar.dart';

/// The doctor as the TV will show them: photo, name, degrees, designation,
/// workplace, specialty and registration number (whatever was filled in).
class DoctorSummary extends StatelessWidget {
  const DoctorSummary({super.key, required this.doctor, this.compact = false});

  final Doctor doctor;

  /// Smaller text and picture, for short (landscape) screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted =
        (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final lines = [
      if (doctor.degrees.isNotEmpty) doctor.degrees.join(', '),
      ?doctor.designation,
      ?doctor.workplace,
      ?doctor.specialty,
      ?doctor.registrationNumber,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DoctorAvatar(photoPath: doctor.photoPath, size: compact ? 56 : 72),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctor.name, style: theme.textTheme.titleMedium),
              for (final line in lines) Text(line, style: muted),
            ],
          ),
        ),
      ],
    );
  }
}
