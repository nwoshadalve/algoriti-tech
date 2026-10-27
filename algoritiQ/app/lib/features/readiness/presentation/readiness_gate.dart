import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/retry_view.dart';
import '../../../l10n/app_localizations.dart';
import '../application/readiness_controller.dart';
import 'readiness_page.dart';

/// After first-time setup (or immediately on chamber licenses), shows the
/// readiness guide until every required item is done. Re-reads the checklist
/// when the user returns from a system settings page, and returns here if a
/// later change (for example a new screen lock) breaks a requirement.
class ReadinessGate extends ConsumerStatefulWidget {
  const ReadinessGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReadinessGate> createState() => _ReadinessGateState();
}

class _ReadinessGateState extends ConsumerState<ReadinessGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(readinessControllerProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(readinessControllerProvider);
    return report.when(
      // A blink while Android answers.
      loading: () => const Scaffold(),
      error: (_, _) => RetryView(
        message: AppLocalizations.of(context).setupLoadFailed,
        onRetry: () => ref.invalidate(readinessControllerProvider),
      ),
      data: (data) => data.acknowledged && data.requiredDone
          ? widget.child
          : ReadinessPage(report: data),
    );
  }
}
