// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/printer.dart';
import '../domain/printer_store.dart';

final class PrefsPrinterStore implements PrinterStore {
  const PrefsPrinterStore();

  static const _nameKey = 'printer.name';
  static const _addressKey = 'printer.address';

  @override
  Future<PrinterDevice?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_addressKey);
    if (address == null) return null;
    return PrinterDevice(
      name: prefs.getString(_nameKey) ?? address,
      address: address,
    );
  }

  @override
  Future<void> write(PrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, device.name);
    await prefs.setString(_addressKey, device.address);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_addressKey);
  }
}
