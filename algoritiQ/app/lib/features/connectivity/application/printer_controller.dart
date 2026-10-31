// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../platform/printer_gateway.dart';
import '../data/prefs_printer_store.dart';
import '../domain/printer.dart';
import '../domain/printer_store.dart';

/// Waits between automatic connection attempts; the last one repeats.
final printerRetryDelaysProvider = Provider<List<Duration>>(
  (ref) => const [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 10),
    Duration(seconds: 30),
    Duration(seconds: 60),
  ],
);

final printerStoreProvider = Provider<PrinterStore>(
  (ref) => const PrefsPrinterStore(),
);

final printerControllerProvider =
    NotifierProvider<PrinterController, PrinterState>(PrinterController.new);

final class PrinterState {
  const PrinterState({
    this.loaded = false,
    this.access = BluetoothAccess.ready,
    this.link = PrinterLink.notPaired,
    this.saved,
    this.scanning = false,
    this.found = const [],
    this.attempt = 0,
    this.nextTryAt,
    this.working = false,
  });

  /// The saved printer has been read; before that the page shows a loader.
  final bool loaded;
  final BluetoothAccess access;
  final PrinterLink link;
  final PrinterDevice? saved;
  final bool scanning;

  /// Paired and nearby printers, for the picker.
  final List<PrinterDevice> found;

  /// Failed automatic attempts since the last success.
  final int attempt;

  /// When the tablet will try again by itself; null when it is not waiting.
  final DateTime? nextTryAt;

  /// Pairing or printing is in progress.
  final bool working;

  PrinterState copyWith({
    bool? loaded,
    BluetoothAccess? access,
    PrinterLink? link,
    Object? saved = _keep,
    bool? scanning,
    List<PrinterDevice>? found,
    int? attempt,
    Object? nextTryAt = _keep,
    bool? working,
  }) {
    return PrinterState(
      loaded: loaded ?? this.loaded,
      access: access ?? this.access,
      link: link ?? this.link,
      saved: identical(saved, _keep) ? this.saved : saved as PrinterDevice?,
      scanning: scanning ?? this.scanning,
      found: found ?? this.found,
      attempt: attempt ?? this.attempt,
      nextTryAt: identical(nextTryAt, _keep)
          ? this.nextTryAt
          : nextTryAt as DateTime?,
      working: working ?? this.working,
    );
  }

  static const _keep = Object();
}

/// What happened when the receptionist chose a printer.
enum ChooseOutcome { connected, rejected, failed, bluetoothOff, denied }

/// Owns the printer connection: pairs once, then reconnects by itself whenever
/// the link drops, with growing waits so a printer that is switched off does
/// not drain the tablet.
class PrinterController extends Notifier<PrinterState> {
  Timer? _retry;
  StreamSubscription<PrinterEvent>? _events;
  var _connecting = false;
  var _disposed = false;

  PrinterGateway get _gateway => ref.read(printerGatewayProvider);
  PrinterStore get _store => ref.read(printerStoreProvider);

  @override
  PrinterState build() {
    ref.onDispose(() {
      _disposed = true;
      _retry?.cancel();
      _events?.cancel();
    });
    _events = _gateway.events.listen(_onEvent, onError: (Object _) {});
    unawaited(_start());
    return const PrinterState();
  }

  Future<void> _start() async {
    final saved = await _store.read();
    BluetoothAccess access;
    try {
      access = await _gateway.access();
    } catch (_) {
      access = BluetoothAccess.missing;
    }
    if (_disposed) return;
    state = state.copyWith(
      loaded: true,
      saved: saved,
      access: access,
      link: _restingLink(access, saved),
    );
    if (saved != null && access == BluetoothAccess.ready) {
      await _attempt();
    }
  }

  PrinterLink _restingLink(BluetoothAccess access, PrinterDevice? saved) {
    if (access != BluetoothAccess.ready) return PrinterLink.blocked;
    return saved == null ? PrinterLink.notPaired : PrinterLink.disconnected;
  }

  void _onEvent(PrinterEvent event) {
    switch (event) {
      case PrinterLinkChanged(:final connected):
        if (state.saved == null) return;
        if (connected) {
          _markConnected();
        } else if (state.link == PrinterLink.connected) {
          state = state.copyWith(link: PrinterLink.disconnected);
          _scheduleRetry(first: true);
        }
      case BluetoothAccessChanged(:final access):
        unawaited(_onAccess(access));
      case PrinterFound(:final device):
        if (!state.found.contains(device)) {
          state = state.copyWith(found: [...state.found, device]);
        }
      case PrinterScanEnded():
        state = state.copyWith(scanning: false);
    }
  }

  Future<void> _onAccess(BluetoothAccess access) async {
    _retry?.cancel();
    final saved = state.saved;
    state = state.copyWith(
      access: access,
      link: _restingLink(access, saved),
      nextTryAt: null,
    );
    if (saved != null && access == BluetoothAccess.ready) {
      state = state.copyWith(attempt: 0);
      await _attempt();
    }
  }

  /// One connection attempt; schedules the next one if it fails.
  Future<ConnectOutcome?> _attempt() async {
    final saved = state.saved;
    if (saved == null || _connecting) return null;
    if (state.link == PrinterLink.connected) return ConnectOutcome.connected;
    _connecting = true;
    _retry?.cancel();
    state = state.copyWith(link: PrinterLink.connecting, nextTryAt: null);
    ConnectOutcome outcome;
    try {
      outcome = await _gateway.connect(saved.address);
    } catch (_) {
      outcome = ConnectOutcome.failed;
    } finally {
      _connecting = false;
    }
    if (_disposed || state.saved != saved) return outcome;
    switch (outcome) {
      case ConnectOutcome.connected:
        _markConnected();
      case ConnectOutcome.bluetoothOff:
        state = state.copyWith(
          access: BluetoothAccess.off,
          link: PrinterLink.blocked,
        );
      case ConnectOutcome.denied:
        state = state.copyWith(
          access: BluetoothAccess.denied,
          link: PrinterLink.blocked,
        );
      case ConnectOutcome.failed:
        state = state.copyWith(
          link: PrinterLink.disconnected,
          attempt: state.attempt + 1,
        );
        _scheduleRetry();
    }
    return outcome;
  }

  void _markConnected() {
    _retry?.cancel();
    state = state.copyWith(
      link: PrinterLink.connected,
      attempt: 0,
      nextTryAt: null,
    );
  }

  void _scheduleRetry({bool first = false}) {
    _retry?.cancel();
    final index = first ? 0 : state.attempt - 1;
    final delays = ref.read(printerRetryDelaysProvider);
    final wait = delays[index.clamp(0, delays.length - 1)];
    state = state.copyWith(nextTryAt: DateTime.now().add(wait));
    _retry = Timer(wait, () => unawaited(_attempt()));
  }

  /// "Connect now" on the page: now, and the waits start over.
  Future<ConnectOutcome?> retryNow() async {
    if (state.saved == null) return null;
    final access = await _gateway.access();
    if (access != BluetoothAccess.ready) {
      state = state.copyWith(access: access, link: PrinterLink.blocked);
      return null;
    }
    state = state.copyWith(access: access, attempt: 0);
    return _attempt();
  }

  Future<void> allowBluetooth() async {
    final access = await _gateway.requestAccess();
    await _onAccess(access);
  }

  Future<void> turnBluetoothOn() => _gateway.requestEnable();

  /// Lists paired printers, then scans for new ones.
  Future<void> scan() async {
    state = state.copyWith(found: const [], scanning: true);
    try {
      final paired = await _gateway.paired();
      state = state.copyWith(found: paired);
      await _gateway.startScan();
    } catch (_) {
      state = state.copyWith(scanning: false);
    }
  }

  Future<void> stopScan() async {
    state = state.copyWith(scanning: false);
    try {
      await _gateway.stopScan();
    } catch (_) {}
  }

  /// Pairs (once) with [device], remembers it, and connects.
  Future<ChooseOutcome> choose(PrinterDevice device) async {
    state = state.copyWith(working: true);
    await stopScan();
    try {
      final alreadyPaired = (await _gateway.paired()).contains(device);
      if (!alreadyPaired) {
        final paired = await _gateway.pair(device.address);
        if (paired == PairOutcome.rejected) return ChooseOutcome.rejected;
        if (paired == PairOutcome.failed) return ChooseOutcome.failed;
      }
      await _store.write(device);
      _retry?.cancel();
      await _gateway.disconnect();
      state = state.copyWith(
        saved: device,
        link: PrinterLink.disconnected,
        attempt: 0,
      );
      final outcome = await _attempt();
      return switch (outcome) {
        ConnectOutcome.connected => ChooseOutcome.connected,
        ConnectOutcome.bluetoothOff => ChooseOutcome.bluetoothOff,
        ConnectOutcome.denied => ChooseOutcome.denied,
        _ => ChooseOutcome.failed,
      };
    } finally {
      state = state.copyWith(working: false);
    }
  }

  /// Sends a ready-made print job (ESC/POS bytes) to the printer.
  Future<PrintOutcome> print(Uint8List job) async {
    state = state.copyWith(working: true);
    try {
      final outcome = await _gateway.print(job);
      if (outcome == PrintOutcome.notConnected) {
        state = state.copyWith(link: PrinterLink.disconnected);
        _scheduleRetry(first: true);
      }
      return outcome;
    } finally {
      state = state.copyWith(working: false);
    }
  }
}
