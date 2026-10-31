// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/card_page.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/password_text_field.dart';
import '../../../l10n/app_localizations.dart';
import '../application/access_service.dart';
import '../application/tablet_session.dart';
import '../domain/access_policy.dart';
import 'notice_banner.dart';
import 'reset_progress.dart';

enum _Step { username, key, password }

/// Resets a forgotten password in three steps: the username, the activation
/// key this tablet was activated with (checked by the tablet, which then
/// allows one new password), and the new password. Works offline. Two columns
/// on wide landscape screens.
///
/// The first step asks nothing of the tablet, so it never says whether the
/// username exists; the key check refuses a wrong key and an unknown username
/// in the same words.
class ResetPasswordCard extends ConsumerStatefulWidget {
  const ResetPasswordCard({
    super.key,
    required this.onDone,
    required this.onBack,
  });

  /// The password was changed.
  final VoidCallback onDone;

  /// Back to sign-in.
  final VoidCallback onBack;

  @override
  ConsumerState<ResetPasswordCard> createState() => _ResetPasswordCardState();
}

class _ResetPasswordCardState extends ConsumerState<ResetPasswordCard> {
  final _username = TextEditingController();
  final _key = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  _Step _step = _Step.username;
  String? _ticket;
  bool _busy = false;
  String? _formError;
  String? _usernameError;
  String? _keyError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _username.dispose();
    _key.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String get _name => AccessPolicy.normalizeUsername(_username.text);

  void _toKey(AppLocalizations l10n) {
    if (_name.isEmpty) {
      setState(() => _usernameError = l10n.resetNeedUsername);
      return;
    }
    setState(() {
      _usernameError = null;
      _formError = null;
      _step = _Step.key;
    });
  }

  Future<void> _checkKey(AppLocalizations l10n) async {
    if (_busy) return;
    if (_key.text.trim().isEmpty) {
      setState(() => _keyError = l10n.resetNeedKey);
      return;
    }
    setState(() {
      _busy = true;
      _keyError = null;
      _formError = null;
    });
    final result = await ref
        .read(tabletSessionProvider.notifier)
        .startReset(username: _username.text, activationKey: _key.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case ResetTicketIssued(:final ticket):
          _ticket = ticket;
          _step = _Step.password;
        case ResetRefused():
          _formError = l10n.resetRefused;
        case ResetThrottled(:final retryAfter):
          _formError = l10n.signInWait(retryAfter.inSeconds + 1);
      }
    });
  }

  Future<void> _finish(AppLocalizations l10n) async {
    final ticket = _ticket;
    if (_busy || ticket == null) return;
    final problem = _password.text.isEmpty
        ? null
        : AccessPolicy.check(username: _name, password: _password.text);
    final passwordProblem = _problemText(l10n, problem);
    setState(() {
      _passwordError = _password.text.isEmpty
          ? l10n.passwordNeeded
          : passwordProblem;
      _confirmError = _confirm.text != _password.text
          ? l10n.passwordsDiffer
          : null;
    });
    if (_passwordError != null || _confirmError != null) return;

    setState(() {
      _busy = true;
      _formError = null;
    });
    final result = await ref
        .read(tabletSessionProvider.notifier)
        .finishReset(ticket: ticket, newPassword: _password.text);
    if (!mounted) return;
    switch (result) {
      case PasswordWasReset():
        widget.onDone();
      case ResetTicketInvalid():
        setState(() {
          _busy = false;
          _ticket = null;
          _key.clear();
          _step = _Step.key;
          _formError = l10n.resetExpired;
        });
      case ResetCredentialsRefused(:final problem):
        setState(() {
          _busy = false;
          _passwordError = _problemText(l10n, problem);
        });
      case ResetThrottled(:final retryAfter):
        setState(() {
          _busy = false;
          _formError = l10n.signInWait(retryAfter.inSeconds + 1);
        });
    }
  }

  String? _problemText(AppLocalizations l10n, CredentialProblem? problem) =>
      switch (problem) {
        CredentialProblem.passwordTooShort => l10n.passwordTooShort,
        CredentialProblem.passwordTooLong => l10n.passwordTooLong,
        CredentialProblem.passwordContainsUsername => l10n.passwordHasUsername,
        _ => null,
      };

  /// One step back; going back from the password step drops the ticket.
  void _back() {
    setState(() {
      _formError = null;
      if (_step == _Step.password) {
        _ticket = null;
        _key.clear();
        _password.clear();
        _confirm.clear();
        _step = _Step.key;
      } else if (_step == _Step.key) {
        _step = _Step.username;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final twoColumn = CardPage.isTwoColumn(context);

    final (title, intro) = switch (_step) {
      _Step.username => (l10n.resetTitle, l10n.resetIntro),
      _Step.key => (l10n.resetKeyTitle, l10n.resetKeyIntro),
      _Step.password => (
        l10n.resetPasswordTitle,
        l10n.resetPasswordIntro(_name),
      ),
    };
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResetProgress(
          current: _step.index + 1,
          labels: [
            l10n.resetStepUsername,
            l10n.resetStepKey,
            l10n.resetStepPassword,
          ],
        ),
        const SizedBox(height: Spacing.md),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          intro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (_formError != null) ...[
          const SizedBox(height: Spacing.md),
          NoticeBanner(message: _formError!, isError: true),
        ],
      ],
    );
    final form = switch (_step) {
      _Step.username => _form(
        fields: [
          LabeledTextField(
            label: l10n.signInUsernameLabel,
            controller: _username,
            errorText: _usernameError,
            capitalization: TextCapitalization.none,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: () => _toKey(l10n),
          ),
        ],
        primary: LoadingButton(
          label: l10n.resetContinue,
          onPressed: () => _toKey(l10n),
        ),
        secondaryLabel: l10n.resetBack,
        onSecondary: widget.onBack,
      ),
      _Step.key => _form(
        fields: [
          LabeledTextField(
            label: l10n.resetKeyLabel,
            controller: _key,
            enabled: !_busy,
            errorText: _keyError,
            hint: l10n.resetKeyHint,
            capitalization: TextCapitalization.none,
            autocorrect: false,
            maxLines: 3,
          ),
        ],
        primary: LoadingButton(
          label: l10n.resetContinue,
          loadingLabel: l10n.resetChecking,
          isLoading: _busy,
          onPressed: () => _checkKey(l10n),
        ),
        secondaryLabel: l10n.resetPrevious,
        onSecondary: _busy ? null : _back,
      ),
      _Step.password => _form(
        fields: [
          PasswordTextField(
            label: l10n.resetNewPasswordLabel,
            controller: _password,
            enabled: !_busy,
            errorText: _passwordError,
            hint: l10n.resetPasswordHint,
            textInputAction: TextInputAction.next,
          ),
          PasswordTextField(
            label: l10n.resetConfirmLabel,
            controller: _confirm,
            enabled: !_busy,
            errorText: _confirmError,
            textInputAction: TextInputAction.done,
            onSubmitted: () => _finish(l10n),
          ),
        ],
        primary: LoadingButton(
          label: l10n.resetButton,
          loadingLabel: l10n.resetBusy,
          isLoading: _busy,
          onPressed: () => _finish(l10n),
        ),
        secondaryLabel: l10n.resetPrevious,
        onSecondary: _busy ? null : _back,
      ),
    };

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

  Widget _form({
    required List<Widget> fields,
    required Widget primary,
    required String secondaryLabel,
    required VoidCallback? onSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, field) in fields.indexed) ...[
          if (i > 0) const SizedBox(height: Spacing.md),
          field,
        ],
        const SizedBox(height: Spacing.lg),
        primary,
        const SizedBox(height: Spacing.sm),
        Align(
          child: TextButton(
            onPressed: onSecondary,
            child: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }
}
