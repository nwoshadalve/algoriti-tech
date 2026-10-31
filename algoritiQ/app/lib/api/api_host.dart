// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/security/secure_storage_secret_store.dart';
import '../features/home/application/receptionist_scope_service.dart';
import '../features/home/application/receptionist_work.dart';
import '../features/access/application/access_providers.dart';
import '../features/clinic/application/clinic_providers.dart';
import '../features/backup/application/backup_providers.dart';
import '../features/monitoring/application/monitoring_providers.dart';
import '../features/queue/application/queue_providers.dart';
import '../features/queue_board/application/queue_board_providers.dart';
import '../features/audit/application/audit_query_service.dart';
import '../platform/keep_alive_gateway.dart';
import 'local_api_server.dart';
import 'mdns/local_name_responder.dart';
import 'mdns/mdns_socket.dart';
import 'tls_identity.dart';
import 'web_site.dart';

/// Where the running API can be reached.
final class ApiEndpoint {
  const ApiEndpoint({
    required this.port,
    required this.addresses,
    required this.fingerprint,
    this.localName,
  });

  final int port;

  /// This tablet's addresses on the local network (may be empty offline).
  final List<String> addresses;

  /// SHA-256 of the HTTPS certificate, to compare with the browser's.
  final String fingerprint;

  /// The name other devices on the Wi-Fi can use (`algoritiq.local`), once the
  /// tablet has claimed it; null before that or when no name was free.
  final String? localName;

  /// `https://192.168.0.20:8443`, or null while the tablet has no network.
  String? get url =>
      addresses.isEmpty ? null : 'https://${addresses.first}:$port';

  /// `https://algoritiq.local:8443`, or null while the tablet has no name.
  String? get nameUrl => localName == null ? null : 'https://$localName:$port';

  ApiEndpoint copyWith({List<String>? addresses, String? localName}) =>
      ApiEndpoint(
        port: port,
        addresses: addresses ?? this.addresses,
        fingerprint: fingerprint,
        localName: localName ?? this.localName,
      );
}

/// Starts and stops the tablet's local API.
abstract interface class ApiHost {
  Future<ApiEndpoint> start();

  /// Looks at the network again (Wi-Fi may have changed).
  Future<List<String>> currentAddresses();

  /// Re-reads addresses and re-announces the local name (call when Wi-Fi changes).
  Future<void> refreshLocalNetwork();

  /// The local network name, each time it is claimed or lost.
  Stream<String?> get localNames;

  Future<void> stop();
}

/// The real host: HTTPS with the tablet's self-signed identity, and a name on
/// the local network.
final class LocalApiHost implements ApiHost {
  LocalApiHost({
    required this._createServer,
    required this._tls,
    this.port = 8443,
    required this._addresses,
    this._names,
  });

  final Future<LocalApiServer> Function() _createServer;
  final TlsIdentityStore _tls;
  final Future<List<String>> Function() _addresses;
  final LocalNameResponder? _names;
  final int port;

  LocalApiServer? _server;

  @override
  Future<ApiEndpoint> start() async {
    final identity = await _tls.loadOrCreate();
    final server = await _createServer();
    await server.start(context: identity.toSecurityContext(), port: port);
    _server = server;
    await _startName();
    return ApiEndpoint(
      port: port,
      addresses: await _addresses(),
      fingerprint: identity.fingerprint,
      localName: _names?.name,
    );
  }

  /// The name is a convenience: the API works by address without it.
  Future<void> _startName() async {
    try {
      await _names?.start();
    } on Exception {
      // No multicast on this network; the address still works.
    }
  }

  @override
  Future<List<String>> currentAddresses() => _addresses();

  @override
  Future<void> refreshLocalNetwork() =>
      _names?.refreshAfterNetworkChange() ?? Future<void>.value();

  @override
  Stream<String?> get localNames => _names?.names ?? const Stream.empty();

  @override
  Future<void> stop() async {
    await _names?.stop();
    await _server?.stop();
    _server = null;
  }
}

final apiHostProvider = Provider<ApiHost>((ref) {
  final gateway = ref.watch(keepAliveGatewayProvider);
  final host = LocalApiHost(
    addresses: gateway.localAddresses,
    createServer: () async => LocalApiServer(
      access: () => ref.read(accessServiceProvider.future),
      users: () => ref.read(userManagementServiceProvider.future),
      doctor: () async => ref.read(doctorProfileServiceProvider),
      chambers: () async => ref.read(chamberServiceProvider),
      receptionistScope: () async => ref.read(receptionistScopeServiceProvider),
      monitoring: ref.read(monitoringServiceProvider),
      backup: () => ref.read(backupServiceProvider.future),
      queue: () async => ref.read(queueServiceProvider),
      queueBoard: () async => ref.read(queueBoardServiceProvider),
      auditQuery: ref.read(auditQueryServiceProvider),
      web: WebSite(BundledWebFiles()),
    ),
    tls: TlsIdentityStore(ref.watch(secretStoreProvider)),
    names: LocalNameResponder(
      open: UdpMdnsSocket.open,
      addresses: gateway.localAddresses,
      addressesV6: gateway.localAddressesV6,
    ),
  );
  ref.onDispose(host.stop);
  return host;
});
