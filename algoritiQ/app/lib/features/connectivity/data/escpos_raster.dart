// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'dart:typed_data';

/// A 58 mm printer prints 384 dots across.
const printerDotsWide = 384;

/// Turns a picture into an ESC/POS job: initialise, `GS v 0` raster, feed.
///
/// [rgba] is [width] x [height] pixels, 4 bytes each. A pixel prints black
/// when it is opaque and darker than mid-grey; everything else stays white.
/// [width] must be a multiple of 8.
Uint8List encodeRasterJob({
  required Uint8List rgba,
  required int width,
  required int height,
  int feedLines = 3,
}) {
  assert(width % 8 == 0, 'Width must be a multiple of 8 dots.');
  assert(rgba.length == width * height * 4);
  final rowBytes = width ~/ 8;
  final job = BytesBuilder(copy: false)
    ..add(const [0x1B, 0x40])
    ..add([
      0x1D, 0x76, 0x30, 0x00, //
      rowBytes & 0xFF, rowBytes >> 8,
      height & 0xFF, height >> 8,
    ]);

  final raster = Uint8List(rowBytes * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = (y * width + x) * 4;
      final alpha = rgba[p + 3];
      // Integer luminance, weighted for the eye; transparent counts as white.
      final luma = (rgba[p] * 77 + rgba[p + 1] * 151 + rgba[p + 2] * 28) >> 8;
      final black = alpha > 127 && luma < 140;
      if (black) raster[y * rowBytes + (x >> 3)] |= 0x80 >> (x & 7);
    }
  }
  job
    ..add(raster)
    ..add([0x1B, 0x64, feedLines]);
  return job.takeBytes();
}
