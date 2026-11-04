// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/board_models.dart';
import 'queue_desk_format.dart';

const _fieldIconBox = BoxConstraints(minWidth: 44, minHeight: 40);

/// Search box and what it found.
class DeskSearchStep extends StatelessWidget {
  const DeskSearchStep({
    super.key,
    required this.query,
    required this.results,
    required this.searching,
    required this.failed,
    required this.longEnough,
    required this.onPick,
  });

  final TextEditingController query;
  final List<PatientSummary> results;
  final bool searching;
  final bool failed;
  final bool longEnough;
  final ValueChanged<PatientSummary> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final Widget status;
    if (searching) {
      status = Center(child: BrandLoader(semanticLabel: l10n.deskSearching));
    } else if (failed) {
      status = Text(l10n.deskSearchFailed, style: muted);
    } else if (!longEnough) {
      status = Text(l10n.deskSearchStart, style: muted);
    } else if (results.isEmpty) {
      status = Text(l10n.deskNoMatchHint, style: muted);
    } else {
      status = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final p in results) ...[
            DeskPatientTile(patient: p, onTap: () => onPick(p)),
            const SizedBox(height: Spacing.xs),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The hint lives inside the field, not above and below it: with the
        // keyboard up on a landscape tablet every line counts, and the
        // suggestions must stay in view while typing.
        ListenableBuilder(
          listenable: query,
          builder: (context, _) => TextField(
            controller: query,
            autofocus: true,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            // The search key closes the keyboard so the whole list shows.
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              prefixIconConstraints: _fieldIconBox,
              suffixIcon: query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.deskSearchClear,
                      icon: const Icon(Icons.close),
                      onPressed: query.clear,
                    ),
              suffixIconConstraints: _fieldIconBox,
              hintText: l10n.deskSearchHint,
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        status,
      ],
    );
  }
}

String _initial(String name) {
  final chars = name.trim().characters;
  return chars.isEmpty ? '?' : chars.first;
}

/// "ID · phone", then age and gender when known.
String _meta(PatientSummary p, AppLocalizations l10n) {
  final parts = [
    p.clinicPatientId,
    queueDeskDisplayPhone(p.phoneNormalized),
    ?p.ageLabel,
    if (p.gender == PatientGender.male) l10n.deskGenderMale,
    if (p.gender == PatientGender.female) l10n.deskGenderFemale,
    if (p.gender == PatientGender.other) l10n.deskGenderOther,
  ];
  return parts.where((s) => s.isNotEmpty).join(' · ');
}

class DeskPatientAvatar extends StatelessWidget {
  const DeskPatientAvatar(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      child: Text(
        _initial(name),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// One search result; the whole row is the tap target.
class DeskPatientTile extends StatelessWidget {
  const DeskPatientTile({
    super.key,
    required this.patient,
    required this.onTap,
  });

  final PatientSummary patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final shape = BorderRadius.circular(Radii.field);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: shape,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: Row(
              children: [
                DeskPatientAvatar(patient.bengaliName),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.bengaliName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _meta(patient, l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The chosen patient, with the way to correct their details.
class DeskPatientCard extends StatelessWidget {
  const DeskPatientCard({
    super.key,
    required this.patient,
    required this.onEdit,
  });

  final PatientSummary patient;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            DeskPatientAvatar(patient.bengaliName),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.bengaliName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _meta(patient, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onEdit, child: Text(l10n.deskEditPatient)),
          ],
        ),
      ),
    );
  }
}
