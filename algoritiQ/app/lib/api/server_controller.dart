// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_host.dart';
import '../platform/keep_alive_gateway.dart';

sealed class ServerState {
  const ServerState();
}

final class ServerStarting extends ServerState {
  const ServerStarting();
}

final class ServerRunning extends ServerState {
  const ServerRunning(this.endpoint);

  final ApiEndpoint endpoint;
}

/// The server could not start (for example the port is taken). The screen
/// offers a retry; the reason goes to the log, not to the user.
final class ServerFailed extends ServerState {
  const ServerFailed();
}

final serverControllerProvider =
    NotifierProvider<ServerController, ServerState>(ServerController.new);

/// Keeps the tablet's local API running while the app is.
class ServerController extends Notifier<ServerState> {
  StreamSubscription<String?>? _names;
  StreamSubscription<void>? _network;

  /// The local network name as last heard; it may arrive before or after the
  /// server reports it is running.
  String? _localName;

  @override
  ServerState build() {
    ref.onDispose(() {
      _names?.cancel();
      _network?.cancel();
    });
    final gateway = ref.read(keepAliveGatewayProvider);
    _network ??= gateway.networkChanges.listen((_) {
      unawaited(_onNetworkChanged());
    });
    unawaited(_start());
    return const ServerStarting();
  }

  Future<void> retry() async {
    state = const ServerStarting();
    await _start();
  }

  /// Re-reads the tablet's addresses (call when the Wi-Fi may have changed).
  Future<void> refreshAddresses() async {
    final current = state;
    if (current is! ServerRunning) return;
    final host = ref.read(apiHostProvider);
    await host.refreshLocalNetwork();
    if (!ref.mounted) return;
    final addresses = await host.currentAddresses();
    if (!ref.mounted) return;
    state = ServerRunning(current.endpoint.copyWith(addresses: addresses));
  }

  Future<void> _onNetworkChanged() async {
    final host = ref.read(apiHostProvider);
    await host.refreshLocalNetwork();
    if (!ref.mounted) return;
    await refreshAddresses();
  }

  void _onName(String? name) {
    _localName = name;
    final current = state;
    if (current is! ServerRunning) return;
    state = ServerRunning(
      ApiEndpoint(
        port: current.endpoint.port,
        addresses: current.endpoint.addresses,
        fingerprint: current.endpoint.fingerprint,
        localName: name,
      ),
    );
  }

  Future<void> _start() async {
    final host = ref.read(apiHostProvider);
    _names ??= host.localNames.listen(_onName);
    try {
      final endpoint = await host.start();
      if (!ref.mounted) return;
      state = ServerRunning(
        endpoint.localName == null
            ? endpoint.copyWith(localName: _localName)
            : endpoint,
      );
    } on Exception {
      if (ref.mounted) state = const ServerFailed();
    }
  }
}
