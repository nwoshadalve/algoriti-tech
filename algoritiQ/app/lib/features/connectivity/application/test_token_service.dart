// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../clinic/application/clinic_providers.dart';
import '../../clinic/domain/chamber.dart';
import '../../clinic/domain/clinic_repository.dart';
import '../../clinic/domain/doctor.dart';
import '../../home/application/receptionist_work.dart';
import '../data/token_slip_renderer.dart';
import '../domain/printer.dart';
import '../domain/token_slip.dart';
import 'printer_controller.dart';

/// What happened when the receptionist asked for a test token.
enum TestTokenOutcome { printed, failed, notConnected, noDetails }

final testTokenServiceProvider = Provider<TestTokenService>(
  (ref) => TestTokenService(
    clinic: ref.watch(clinicRepositoryProvider),
    scopeId: () {
      final work = ref.read(receptionistWorkProvider);
      return work is ReceptionistWorkReady ? work.selected.id : null;
    },
    now: ref.watch(clockProvider),
    print: (job) => ref.read(printerControllerProvider.notifier).print(job),
  ),
);

/// Prints a sample token with the real chamber and doctor names, so the
/// receptionist can see what patients will get. The number is a dummy and the
/// queue is Regular.
class TestTokenService {
  TestTokenService({
    required ClinicRepository clinic,
    required String? Function() scopeId,
    required DateTime Function() now,
    required Future<PrintOutcome> Function(Uint8List job) print,
    Future<Uint8List> Function(TokenSlip slip)? render,
  }) : _clinic = clinic,
       _scopeId = scopeId,
       _now = now,
       _print = print,
       _render = render ?? const TokenSlipRenderer().render;

  final ClinicRepository _clinic;
  final String? Function() _scopeId;
  final DateTime Function() _now;
  final Future<PrintOutcome> Function(Uint8List job) _print;
  final Future<Uint8List> Function(TokenSlip slip) _render;

  /// The dummy numbers on a test token.
  static const testTokenNumber = 1;
  static const testRegistrationId = 'PT-00-00001';

  Future<TestTokenOutcome> run() async {
    final slip = await buildSlip();
    if (slip == null) return TestTokenOutcome.noDetails;
    return _printSlip(slip);
  }

  /// Same as [run], but uses the first doctor and chamber when no receptionist
  /// scope is selected (admin monitoring on the web).
  Future<TestTokenOutcome> runForAdmin() async {
    final slip = await buildSlip() ?? await _fallbackSlip();
    if (slip == null) return TestTokenOutcome.noDetails;
    return _printSlip(slip);
  }

  Future<TestTokenOutcome> _printSlip(TokenSlip slip) async {
    final job = await _render(slip);
    return switch (await _print(job)) {
      PrintOutcome.printed => TestTokenOutcome.printed,
      PrintOutcome.failed => TestTokenOutcome.failed,
      PrintOutcome.notConnected => TestTokenOutcome.notConnected,
    };
  }

  /// The slip for the chamber or doctor the receptionist is working at;
  /// null when that cannot be found.
  Future<TokenSlip?> buildSlip() async {
    final scopeId = _scopeId();
    if (scopeId == null) return null;
    final chambers = await _clinic.watchChambers().first;
    final doctors = await _clinic.watchDoctors().first;

    Chamber? chamber = _first(chambers, (c) => c.id == scopeId);
    Doctor? doctor;
    if (chamber != null) {
      doctor = _first(doctors, (d) => d.id == chamber!.doctorId);
    } else {
      doctor = _first(doctors, (d) => d.id == scopeId);
      if (doctor != null) {
        chamber = _first(chambers, (c) => c.doctorId == doctor!.id);
      }
    }
    if (doctor == null) return null;

    return TokenSlip(
      chamberName: chamber?.name ?? doctor.workplace ?? '',
      doctorName: doctor.name,
      queueType: QueueType.regular,
      tokenNumber: testTokenNumber,
      registrationId: testRegistrationId,
      issuedAt: _now(),
    );
  }

  Future<TokenSlip?> _fallbackSlip() async {
    final doctors = await _clinic.watchDoctors().first;
    if (doctors.isEmpty) return null;
    final doctor = doctors.first;
    final chambers = await _clinic.watchChambers().first;
    Chamber? chamber;
    for (final c in chambers) {
      if (c.doctorId == doctor.id) {
        chamber = c;
        break;
      }
    }
    chamber ??= chambers.isNotEmpty ? chambers.first : null;
    return TokenSlip(
      chamberName: chamber?.name ?? doctor.workplace ?? '',
      doctorName: doctor.name,
      queueType: QueueType.regular,
      tokenNumber: testTokenNumber,
      registrationId: testRegistrationId,
      issuedAt: _now(),
    );
  }

  static T? _first<T>(Iterable<T> items, bool Function(T) test) {
    for (final item in items) {
      if (test(item)) return item;
    }
    return null;
  }
}
