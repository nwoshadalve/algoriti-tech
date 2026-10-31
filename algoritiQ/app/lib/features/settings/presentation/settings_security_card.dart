// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/toast/toast_controller.dart';
import '../../../core/widgets/brand_loader.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../../access/application/access_providers.dart';
import '../../access/application/access_service.dart';
import '../../access/application/tablet_session.dart';
import '../../access/data/pin_client_store.dart';
import '../../access/data/sign_in_preference_store.dart';
import '../../access/domain/access_policy.dart';
import '../../access/domain/account.dart';
import 'settings_messages.dart';

/// Password change and quick sign-in PIN for this tablet.
class SettingsSecurityCard extends ConsumerStatefulWidget {
  const SettingsSecurityCard({
    super.key,
    required this.account,
    required this.refreshKey,
    required this.onPasswordChanged,
  });

  final Account account;
  final int refreshKey;
  final VoidCallback onPasswordChanged;

  @override
  ConsumerState<SettingsSecurityCard> createState() =>
      _SettingsSecurityCardState();
}

class _SettingsSecurityCardState extends ConsumerState<SettingsSecurityCard> {
  List<PinDeviceInfo>? _devices;
  PinClientRegistration? _local;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _reloadDevices();
  }

  @override
  void didUpdateWidget(covariant SettingsSecurityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      _reloadDevices();
    }
  }

  Future<void> _reloadDevices() async {
    setState(() => _loading = true);
    final service = await ref.read(accessServiceProvider.future);
    final devices = await service.pinDevices(widget.account);
    final local = await ref.read(pinClientStoreProvider).read();
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _local = local;
      _loading = false;
    });
  }

  Future<void> _openChangePassword() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ChangePasswordSheet(
        account: widget.account,
        onChanged: () {
          widget.onPasswordChanged();
          _reloadDevices();
        },
      ),
    );
  }

  Future<void> _openSetPin({String? replaceId}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) =>
          _SetPinSheet(account: widget.account, replaceDeviceId: replaceId),
    );
    if (saved == true) await _reloadDevices();
  }

  Future<void> _removePinDevice(PinDeviceInfo device) async {
    final service = await ref.read(accessServiceProvider.future);
    await service.removePinDevice(widget.account, device.id);
    final local = await ref.read(pinClientStoreProvider).read();
    if (local?.deviceId == device.id) {
      await ref.read(tabletSessionProvider.notifier).forgetPinRegistration();
    }
    if (!mounted) return;
    ref
        .read(toastControllerProvider.notifier)
        .success(AppLocalizations.of(context).pinRemoved);
    await _reloadDevices();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devices = _devices;
    final local = _local;
    final hereHasPin =
        local != null && (devices?.any((d) => d.id == local.deviceId) ?? false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md + Spacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.securityCardTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.securityCardIntro,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.passwordCardTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.passwordCardIntro,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.md),
                OutlinedButton(
                  onPressed: _openChangePassword,
                  child: Text(l10n.passwordChangeButton),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.md),
              child: Divider(height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.pinCardTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        l10n.pinCardIntro,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Spacing.md),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () => _openSetPin(
                          replaceId: hereHasPin ? local.deviceId : null,
                        ),
                  child: Text(
                    hereHasPin ? l10n.pinChangeButton : l10n.pinSetButton,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: Center(child: BrandLoader()),
              )
            else if (devices == null || devices.isEmpty)
              Text(
                l10n.pinNone,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...devices.map(
                (device) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    device.label.isNotEmpty ? device.label : l10n.pinThisTablet,
                  ),
                  subtitle: device.id == local?.deviceId
                      ? Text(l10n.pinThisTablet)
                      : null,
                  trailing: IconButton(
                    tooltip: l10n.pinRemove,
                    onPressed: () => _removePinDevice(device),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet({required this.account, required this.onChanged});

  final Account account;
  final VoidCallback onChanged;

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _validate(AppLocalizations l10n) {
    if (_current.text.isEmpty || _next.text.isEmpty) {
      return l10n.passwordNeeded;
    }
    if (_next.text != _confirm.text) return l10n.passwordsDiffer;
    final problem = AccessPolicy.check(
      username: widget.account.username,
      password: _next.text,
    );
    if (problem != null) return credentialProblemMessage(l10n, problem);
    if (_next.text == _current.text) return l10n.passwordNewSame;
    return null;
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final validation = _validate(l10n);
    if (validation != null) {
      setState(() => _error = validation);
      return;
    }
    final session = ref.read(tabletSessionProvider);
    if (session == null) return;

    setState(() {
      _busy = true;
      _error = null;
    });
    final service = await ref.read(accessServiceProvider.future);
    final result = await service.changePassword(
      account: widget.account,
      token: session.token,
      currentPassword: _current.text,
      newPassword: _next.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result is PasswordChanged) {
      await ref.read(pinClientStoreProvider).clear();
      await ref
          .read(signInPreferenceStoreProvider)
          .saveMode(SignInMode.password);
      widget.onChanged();
      if (mounted) {
        Navigator.of(context).pop();
        ref
            .read(toastControllerProvider.notifier)
            .success(l10n.passwordChanged);
      }
      return;
    }
    setState(() => _error = changePasswordMessage(l10n, result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inset = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.lg + inset.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.passwordModalTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.lg),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: Spacing.sm),
            ],
            PasswordTextField(
              label: l10n.passwordCurrentLabel,
              controller: _current,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            PasswordTextField(
              label: l10n.passwordNewLabel,
              controller: _next,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            PasswordTextField(
              label: l10n.passwordConfirmLabel,
              controller: _confirm,
              enabled: !_busy,
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
            ),
            const SizedBox(height: Spacing.lg),
            LoadingButton(
              label: l10n.passwordChangeButton,
              loadingLabel: l10n.settingsSaving,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SetPinSheet extends ConsumerStatefulWidget {
  const _SetPinSheet({required this.account, this.replaceDeviceId});

  final Account account;
  final String? replaceDeviceId;

  @override
  ConsumerState<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends ConsumerState<_SetPinSheet> {
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (_pin.text != _confirm.text) {
      setState(() => _error = l10n.pinPinsDiffer);
      return;
    }
    final pinProblem = AccessPolicy.checkPin(_pin.text);
    if (pinProblem != null) {
      setState(() => _error = pinProblemMessage(l10n, pinProblem));
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final service = await ref.read(accessServiceProvider.future);
    final result = await service.setPin(
      account: widget.account,
      password: _password.text,
      pin: _pin.text,
      label: l10n.pinThisTablet,
      replaceDeviceId: widget.replaceDeviceId,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result case PinSet(:final deviceToken, :final device)) {
      await ref
          .read(pinClientStoreProvider)
          .write(
            PinClientRegistration(
              deviceToken: deviceToken,
              deviceId: device.id,
              username: widget.account.username,
              displayName: widget.account.displayName,
            ),
          );
      await ref.read(signInPreferenceStoreProvider).saveMode(SignInMode.pin);
      if (mounted) {
        Navigator.of(context).pop(true);
        ref.read(toastControllerProvider.notifier).success(l10n.pinSetDone);
      }
      return;
    }
    setState(() => _error = setPinMessage(l10n, result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final inset = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        0,
        Spacing.md,
        Spacing.lg + inset.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.pinModalTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Spacing.lg),
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: Spacing.sm),
            ],
            PasswordTextField(
              label: l10n.pinModalPasswordLabel,
              controller: _password,
              enabled: !_busy,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.pinModalPinLabel,
              controller: _pin,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              capitalization: TextCapitalization.none,
              autocorrect: false,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AccessPolicy.pinLength),
              ],
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: Spacing.md),
            LabeledTextField(
              label: l10n.pinModalConfirmLabel,
              controller: _confirm,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              capitalization: TextCapitalization.none,
              autocorrect: false,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AccessPolicy.pinLength),
              ],
              textInputAction: TextInputAction.done,
              onSubmitted: _submit,
            ),
            const SizedBox(height: Spacing.lg),
            LoadingButton(
              label: l10n.pinModalSubmit,
              loadingLabel: l10n.pinModalBusy,
              isLoading: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
