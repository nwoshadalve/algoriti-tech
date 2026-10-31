// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/access_providers.dart';
import '../../access/application/access_service.dart';
import '../../access/domain/account.dart';
import 'settings_messages.dart';

class SettingsProfileCard extends ConsumerStatefulWidget {
  const SettingsProfileCard({
    super.key,
    required this.account,
    required this.onSaved,
  });

  final Account account;
  final ValueChanged<Account> onSaved;

  @override
  ConsumerState<SettingsProfileCard> createState() =>
      _SettingsProfileCardState();
}

class _SettingsProfileCardState extends ConsumerState<SettingsProfileCard> {
  late final _firstName = TextEditingController(text: widget.account.firstName);
  late final _lastName = TextEditingController(text: widget.account.lastName);
  late final _email = TextEditingController(text: widget.account.email);
  late final _phone = TextEditingController(text: widget.account.phone);
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _dirty =>
      _firstName.text.trim() != widget.account.firstName ||
      _lastName.text.trim() != widget.account.lastName ||
      _email.text.trim() != widget.account.email ||
      _phone.text.trim() != widget.account.phone;

  Future<void> _save() async {
    if (_busy || !_dirty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    final service = await ref.read(accessServiceProvider.future);
    final result = await service.updateProfile(
      accountId: widget.account.id,
      firstName: _firstName.text,
      lastName: _lastName.text,
      email: _email.text,
      phone: _phone.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case ProfileSaved(:final account):
        widget.onSaved(account);
        ref.read(toastControllerProvider.notifier).success(l10n.settingsSaved);
      case ProfileRefused(:final problem):
        setState(() => _error = profileProblemMessage(l10n, problem));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsProfileTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.settingsProfileIntro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(error, style: TextStyle(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.fieldFirstName,
              controller: _firstName,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.fieldLastName,
              controller: _lastName,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.fieldEmail,
              controller: _email,
              enabled: !_busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.fieldPhone,
              controller: _phone,
              enabled: !_busy,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.fieldUsername,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              widget.account.username,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.settingsUsernameNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Align(
              alignment: Alignment.centerRight,
              child: LoadingButton(
                label: l10n.settingsSave,
                loadingLabel: l10n.settingsSaving,
                isLoading: _busy,
                onPressed: _dirty ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
