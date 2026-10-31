// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'printer.dart';

/// Remembers the paired printer so the tablet reconnects by itself.
abstract interface class PrinterStore {
  Future<PrinterDevice?> read();

  Future<void> write(PrinterDevice device);

  Future<void> clear();
}
