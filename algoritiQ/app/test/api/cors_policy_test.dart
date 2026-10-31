// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:algoritiq_app/api/cors_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should reflect localhost for private-network preflights in debug CORS mode', () {
    expect(
      accessControlAllowOrigin(
        policy: CorsPolicy.allowAnyOrigin,
        origin: 'http://localhost:5173',
        privateNetworkPreflight: true,
      ),
      'http://localhost:5173',
    );
  });

  test('should reflect any origin in debug CORS mode', () {
    expect(
      accessControlAllowOrigin(
        policy: CorsPolicy.allowAnyOrigin,
        origin: 'https://evil.example',
        privateNetworkPreflight: false,
      ),
      'https://evil.example',
    );
  });

  test('should treat LAN dev hosts as local development origins', () {
    expect(isLocalDevelopmentOrigin('http://192.168.0.20:5173'), isTrue);
  });
}
