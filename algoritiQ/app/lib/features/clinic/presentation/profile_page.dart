// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/clinic_providers.dart';
import '../domain/doctor.dart';
import '../domain/doctor_draft.dart';
import '../domain/photo_store.dart';
import '../domain/setup_outcome.dart';
import 'doctor_photo_field.dart';
import 'profile_controllers.dart';
import 'profile_fields.dart';
import 'setup_card.dart';

/// Setup step 1: the doctor's details, shown on the TV.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _controllers = ProfileControllers();

  // Kept in a field: `ref` can't be used once the widget is disposed.
  late final PhotoStore _photoStore;
  List<String> _degrees = const [];
  String? _photo;

  /// The photo already saved with the doctor, if any.
  String? _savedPhoto;
  String? _existingId;
  SetupOutcome? _problem;
  bool _photoFailed = false;
  bool _busy = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _photoStore = ref.read(photoStoreProvider);
    // Coming back to this step (e.g. after a restart) keeps what was saved.
    final doctors = ref.read(doctorsProvider).value;
    final doctor = (doctors == null || doctors.isEmpty) ? null : doctors.first;
    if (doctor != null) _fill(doctor);
  }

  void _fill(Doctor doctor) {
    _existingId = doctor.id;
    _controllers.fill(doctor);
    _degrees = doctor.degrees;
    _photo = _savedPhoto = doctor.photoPath;
  }

  @override
  void dispose() {
    if (!_saved) unawaited(_discardUnsavedPhoto());
    _controllers.dispose();
    super.dispose();
  }

  /// Deletes a picked photo that was never saved with the doctor.
  Future<void> _discardUnsavedPhoto() async {
    final photo = _photo;
    if (photo != null && photo != _savedPhoto) {
      await _photoStore.remove(photo);
    }
  }

  Future<void> _pickPhoto(PhotoSource source) async {
    try {
      final path = await _photoStore.pick(source);
      if (path == null || !mounted) return;
      await _discardUnsavedPhoto();
      setState(() {
        _photo = path;
        _photoFailed = false;
      });
    } on Exception {
      // Unreadable or unsavable photo: say so and let the user pick again.
      if (mounted) setState(() => _photoFailed = true);
    }
  }

  Future<void> _removePhoto() async {
    await _discardUnsavedPhoto();
    if (mounted) setState(() => _photo = null);
  }

  Future<void> _continue() async {
    setState(() => _busy = true);
    final outcome = await ref
        .read(clinicActionsProvider)
        .saveProfile(
          DoctorDraft(
            name: _controllers.name.text,
            degrees: _degrees,
            designation: _controllers.designation.text,
            workplace: _controllers.workplace.text,
            registrationNumber: _controllers.registration.text,
            specialty: _controllers.specialty.text,
            photoPath: _photo,
          ),
          existingId: _existingId,
        );
    if (!mounted) return;
    if (outcome == SetupOutcome.saved) {
      _saved = true;
      final old = _savedPhoto;
      if (old != null && old != _photo) {
        unawaited(_photoStore.remove(old));
      }
    }
    // On success the gate moves to the next step by itself.
    setState(() {
      _busy = false;
      _problem = outcome == SetupOutcome.saved ? null : outcome;
    });
  }

  /// A message under each required field left blank, after a failed save.
  ProfileErrors _errors(AppLocalizations l10n) {
    if (_problem != SetupOutcome.fieldsMissing) return const ProfileErrors();
    bool blank(TextEditingController c) => c.text.trim().isEmpty;
    return ProfileErrors(
      name: blank(_controllers.name) ? l10n.doctorNameRequired : null,
      designation: blank(_controllers.designation)
          ? l10n.designationRequired
          : null,
      degrees: _degrees.isEmpty ? l10n.degreesRequired : null,
      specialty: blank(_controllers.specialty) ? l10n.specialtyRequired : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final problem = _problem;
    final error = Theme.of(context).colorScheme.error;

    return CardPage(
      wide: true,
      child: SetupCard(
        step: 0,
        title: l10n.profileTitle,
        intro: l10n.profileIntro,
        body: ProfileFields(
          controllers: _controllers,
          degrees: _degrees,
          enabled: !_busy,
          errors: _errors(l10n),
          onDegreesChanged: (degrees) => setState(() => _degrees = degrees),
          photo: (compact) => DoctorPhotoField(
            photoPath: _photo,
            enabled: !_busy,
            onPick: _pickPhoto,
            onRemove: _removePhoto,
            compact: compact,
          ),
          action: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_photoFailed || problem == SetupOutcome.failed) ...[
                Text(
                  _photoFailed ? l10n.photoFailed : l10n.setupSaveFailed,
                  style: TextStyle(color: error),
                ),
                const SizedBox(height: Spacing.md),
              ],
              LoadingButton(
                label: l10n.continueButton,
                loadingLabel: l10n.saving,
                isLoading: _busy,
                onPressed: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
