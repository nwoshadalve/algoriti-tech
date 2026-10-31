// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// Full-screen failure with a way out. Every failed load needs a recovery
/// path; [message] is localized and never a raw exception.
class RetryView extends StatelessWidget {
  const RetryView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.md),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context).retryButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
