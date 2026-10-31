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

  /// Debug/profile: allow any origin (`Access-Control-Allow-Origin: *`).
  allowAnyOrigin,
}

/// Default CORS for the running app: strict on release, open for local web dev.
CorsPolicy defaultCorsPolicy() =>
    kReleaseMode ? CorsPolicy.reflectOrigin : CorsPolicy.allowAnyOrigin;
