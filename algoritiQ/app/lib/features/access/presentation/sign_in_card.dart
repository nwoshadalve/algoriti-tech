// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/access_service.dart';
import '../application/access_providers.dart';
import '../application/tablet_session.dart';
import '../data/pin_client_store.dart';
import '../data/sign_in_preference_store.dart';
import 'notice_banner.dart';
import 'sign_in_method_switch.dart';

/// The tablet's sign-in: PIN or username/email + password.
class SignInCard extends ConsumerStatefulWidget {
  const SignInCard({
    super.key,
    required this.passwordWasReset,
    required this.onForgot,
  });

  final bool passwordWasReset;
  final VoidCallback onForgot;

  @override
  ConsumerState<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends ConsumerState<SignInCard> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _pin = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _busy = false;
  String? _error;
  bool _loaded = false;
  bool _remember = false;
  PinClientRegistration? _pinRegistration;
  SignInMode _mode = SignInMode.password;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadClientState);
  }

  Future<void> _loadClientState() async {
    final pinStore = ref.read(pinClientStoreProvider);
    final prefStore = ref.read(signInPreferenceStoreProvider);
    final registration = await pinStore.read();
    final mode = registration == null
        ? SignInMode.password
        : await prefStore.readMode();
    if (!mounted) return;
    setState(() {
      _pinRegistration = registration;
      _mode = mode;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _pin.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _chooseMode(SignInMode mode) async {
    await ref.read(signInPreferenceStoreProvider).saveMode(mode);
    if (!mounted) return;
    setState(() {
      _mode = mode;
      _error = null;
    });
  }

  Future<void> _dropPin() async {
    await ref.read(tabletSessionProvider.notifier).forgetPinRegistration();
    if (!mounted) return;
    setState(() {
      _pinRegistration = null;
      _mode = SignInMode.password;
      _pin.clear();
      _error = null;
    });
  }

  Future<void> _submitPassword() async {
    final l10n = AppLocalizations.of(context);
    if (_busy) return;
    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = l10n.signInFieldsRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(tabletSessionProvider.notifier)
        .signIn(_username.text, _password.text, remember: _remember);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case LoggedIn():
          break;
        case InvalidCredentials():
          _error = l10n.signInWrong;
          _password.clear();
        case TooManyAttempts(:final retryAfter):
          _error = l10n.signInWait(retryAfter.inSeconds + 1);
          _password.clear();
      }
    });
  }

  Future<void> _submitPin() async {
    final l10n = AppLocalizations.of(context);
    if (_busy) return;
    final digits = _pin.text.trim();
    if (digits.length != 6) {
      setState(() => _error = l10n.pinRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref
        .read(tabletSessionProvider.notifier)
        .signInWithPin(digits);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case PinLoggedIn():
          break;
        case PinWrong(:final attemptsLeft):
          _error = l10n.pinWrong(attemptsLeft);
          _pin.clear();
        case PinLocked():
          _error = l10n.pinLocked;
          _pin.clear();
          unawaited(_dropPin());
        case PinUnavailable():
          _error = l10n.pinLocked;
          unawaited(_dropPin());
        case PinLoginThrottled(:final retryAfter):
          _error = l10n.signInWait(retryAfter.inSeconds + 1);
          _pin.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;
    final twoColumn = CardPage.isTwoColumn(context);
    final pinAvailable = _loaded && _pinRegistration != null;
    final showPin = pinAvailable && _mode == SignInMode.pin;
    final displayName = _pinRegistration?.displayName.isNotEmpty == true
        ? _pinRegistration!.displayName
        : (_pinRegistration?.username ?? '');

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.signInTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          showPin ? l10n.pinLoginIntro : l10n.signInIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (showPin) ...[
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.pinLoginTitle(displayName),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (widget.passwordWasReset && error == null) ...[
          const SizedBox(height: Spacing.md),
          NoticeBanner(message: l10n.resetDone),
        ],
        if (error != null) ...[
          const SizedBox(height: Spacing.md),
          NoticeBanner(message: error, isError: true),
        ],
      ],
    );

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (pinAvailable) ...[
          SignInMethodSwitch(
            mode: _mode,
            onChanged: _chooseMode,
            passwordLabel: l10n.signInPasswordLabel,
            pinLabel: l10n.fieldPin,
            enabled: !_busy,
          ),
          const SizedBox(height: signInMethodSwitchGap),
        ],
        if (showPin) _pinFields(l10n) else _passwordFields(l10n),
      ],
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(twoColumn ? Spacing.md : Spacing.lg),
        child: twoColumn
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: heading),
                  const SizedBox(width: Spacing.xl),
                  Expanded(child: form),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  const SizedBox(height: Spacing.lg),
                  form,
                ],
              ),
      ),
    );
  }

  Widget _passwordFields(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabeledTextField(
          label: l10n.signInIdentifierLabel,
          controller: _username,
          enabled: !_busy,
          capitalization: TextCapitalization.none,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onSubmitted: _passwordFocus.requestFocus,
        ),
        const SizedBox(height: Spacing.md),
        PasswordTextField(
          label: l10n.signInPasswordLabel,
          controller: _password,
          focusNode: _passwordFocus,
          enabled: !_busy,
          textInputAction: TextInputAction.done,
          onSubmitted: _submitPassword,
        ),
        const SizedBox(height: Spacing.md),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _remember,
          onChanged: _busy
              ? null
              : (value) => setState(() => _remember = value ?? false),
          title: Text(l10n.signInRemember),
          subtitle: Text(
            l10n.signInRememberHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        LoadingButton(
          label: l10n.signInButton,
          loadingLabel: l10n.signInBusy,
          isLoading: _busy,
          onPressed: _submitPassword,
        ),
        const SizedBox(height: Spacing.sm),
        Align(
          child: TextButton(
            onPressed: _busy ? null : widget.onForgot,
            child: Text(l10n.signInForgot),
          ),
        ),
      ],
    );
  }

  Widget _pinFields(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.fieldPin,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: _pin,
          enabled: !_busy,
          keyboardType: TextInputType.number,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submitPin(),
        ),
        const SizedBox(height: Spacing.lg),
        LoadingButton(
          label: l10n.signInButton,
          loadingLabel: l10n.signInBusy,
          isLoading: _busy,
          onPressed: _submitPin,
        ),
      ],
    );
  }
}
