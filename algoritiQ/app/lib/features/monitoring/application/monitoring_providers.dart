// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../platform/keep_alive_gateway.dart';
import '../../../platform/system_health_gateway.dart';
import 'monitoring_service.dart';

/// One monitor for the app: it keeps the retry progress that every browser
/// shows.
final monitoringServiceProvider = Provider<MonitoringService>(
  (ref) => MonitoringService(
    health: ref.watch(systemHealthGatewayProvider),
    keepAlive: ref.watch(keepAliveGatewayProvider),
    clock: ref.watch(clockProvider),
  ),
);
