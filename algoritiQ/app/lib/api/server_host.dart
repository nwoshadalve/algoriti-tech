import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server_controller.dart';

/// Keeps the tablet's API running while [child] is on screen, and re-reads
/// the tablet's network address when the app returns to the foreground (the
/// Wi-Fi may have changed).
class ServerHost extends ConsumerStatefulWidget {
  const ServerHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ServerHost> createState() => _ServerHostState();
}

class _ServerHostState extends ConsumerState<ServerHost>
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
      ref.read(serverControllerProvider.notifier).refreshAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watching starts the server and keeps it alive.
    ref.watch(serverControllerProvider);
    return widget.child;
  }
}
