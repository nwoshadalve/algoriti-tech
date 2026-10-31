// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/foundation.dart';

/// How the local API answers browser cross-origin requests (e.g. Vite dev on a laptop).
enum CorsPolicy {
  /// Release builds: reflect the request [Origin] (see [LocalApiServer]).
  reflectOrigin,

  /// Debug/profile: permissive for local web dev (reflects [Origin] when needed).
  allowAnyOrigin,
}

/// Vite and other local dev servers call the tablet API from these hosts.
bool isLocalDevelopmentOrigin(String origin) {
  final uri = Uri.tryParse(origin);
  if (uri == null) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  final host = uri.host.toLowerCase();
  if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
    return true;
  }
  if (host.endsWith('.local')) return true;
  return _isRfc1918Host(host);
}

bool _isRfc1918Host(String host) {
  if (host.startsWith('10.')) return true;
  if (host.startsWith('192.168.')) return true;
  if (host.startsWith('172.')) {
    final second = int.tryParse(host.split('.').elementAtOrNull(1) ?? '');
    if (second != null && second >= 16 && second <= 31) return true;
  }
  return false;
}

/// Default CORS for the running app: strict on release, open for local web dev.
CorsPolicy defaultCorsPolicy() =>
    kReleaseMode ? CorsPolicy.reflectOrigin : CorsPolicy.allowAnyOrigin;

/// Chooses `Access-Control-Allow-Origin` for a browser cross-origin request.
String accessControlAllowOrigin({
  required CorsPolicy policy,
  required String origin,
  required bool privateNetworkPreflight,
}) {
  switch (policy) {
    case CorsPolicy.reflectOrigin:
      return origin;
    case CorsPolicy.allowAnyOrigin:
      // Debug builds: always reflect Origin. Wildcard breaks Authorization
      // headers and private-network access on the actual GET/POST response.
      return origin;
  }
}
