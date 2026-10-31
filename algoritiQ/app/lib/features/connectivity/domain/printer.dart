// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
/// A Bluetooth printer as Android knows it.
final class PrinterDevice {
  const PrinterDevice({required this.name, required this.address});

  final String name;

  /// Bluetooth MAC address, `AA:BB:CC:DD:EE:FF`.
  final String address;

  @override
  bool operator ==(Object other) =>
      other is PrinterDevice && other.address == address;

  @override
  int get hashCode => address.hashCode;
}

/// What the tablet's Bluetooth allows right now.
enum BluetoothAccess { ready, off, denied, missing }

/// Where the connection to the printer stands.
enum PrinterLink {
  /// Bluetooth is off, not allowed, or the tablet has none.
  blocked,

  /// No printer was ever paired with this tablet.
  notPaired,

  /// A printer is paired but not connected; the tablet keeps trying.
  disconnected,

  /// Connecting now.
  connecting,

  connected,
}

enum PairOutcome { paired, rejected, failed }

enum ConnectOutcome { connected, failed, bluetoothOff, denied }

enum PrintOutcome { printed, failed, notConnected }

/// Pushed from the platform when something changes without being asked.
sealed class PrinterEvent {
  const PrinterEvent();
}

/// The link to the saved printer came up or dropped.
final class PrinterLinkChanged extends PrinterEvent {
  const PrinterLinkChanged({required this.connected});
  final bool connected;
}

/// Bluetooth was switched on or off, or permission changed.
final class BluetoothAccessChanged extends PrinterEvent {
  const BluetoothAccessChanged(this.access);
  final BluetoothAccess access;
}

/// A printer turned up while scanning.
final class PrinterFound extends PrinterEvent {
  const PrinterFound(this.device);
  final PrinterDevice device;
}

/// The scan ended (time up or stopped).
final class PrinterScanEnded extends PrinterEvent {
  const PrinterScanEnded();
}
