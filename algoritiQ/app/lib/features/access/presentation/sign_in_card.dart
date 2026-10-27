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
import 'notice_banner.dart';

/// The tablet's sign-in: username, password, and a way to a reset.
class SignInCard extends ConsumerStatefulWidget {
  const SignInCard({
    super.key,
    required this.passwordWasReset,
    required this.onForgot,
  });

  /// Show "Password changed" above the form.
  final bool passwordWasReset;
  final VoidCallback onForgot;

  @override
  ConsumerState<SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends ConsumerState<SignInCard> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
        .signIn(_username.text, _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case LoggedIn():
          // The gate above swaps this screen for the app.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;
    final twoColumn = CardPage.isTwoColumn(context);

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.signInTitle, style: theme.textTheme.headlineSmall),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.signInIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
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
        LabeledTextField(
          label: l10n.signInUsernameLabel,
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
          onSubmitted: _submit,
        ),
        const SizedBox(height: Spacing.lg),
        LoadingButton(
          label: l10n.signInButton,
          loadingLabel: l10n.signInBusy,
          isLoading: _busy,
          onPressed: _submit,
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
}
