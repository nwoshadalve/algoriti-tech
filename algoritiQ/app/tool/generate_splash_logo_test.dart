// Generates the native splash wordmark PNGs from `BrandLogo` so the splash
// is the app's real logo.
//
// Run: flutter test tool/generate_splash_logo_test.dart
//
// Android 12+ shows the splash icon in a 288 dp box, masked to a 192 dp
// circle, so the wordmark is 170 dp wide, centered. Output is xxhdpi (3x).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:algoritiq_app/core/theme/app_theme.dart';
import 'package:algoritiq_app/core/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const splashBoxDp = 288.0;
const splashLogoWidthDp = 170.0;
const splashLogoHeightDp = splashLogoWidthDp * 100 / 370;

const _outputs = {
  Brightness.light:
      'android/app/src/main/res/drawable-xxhdpi/splash_wordmark.png',
  Brightness.dark:
      'android/app/src/main/res/drawable-night-xxhdpi/splash_wordmark.png',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final bytes = await File('assets/fonts/PlusJakartaSans.ttf').readAsBytes();
    final loader = FontLoader(brandFontFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  });

  for (final entry in _outputs.entries) {
    testWidgets('writes ${entry.key.name} splash wordmark', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Theme(
            data: entry.key == Brightness.dark ? AppTheme.dark : AppTheme.light,
            child: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: key,
                child: const SizedBox(
                  width: splashBoxDp,
                  height: splashBoxDp,
                  child: Center(
                    child: BrandLogo.wordmark(height: splashLogoHeightDp),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(entry.value)..createSync(recursive: true);
        file.writeAsBytesSync(data!.buffer.asUint8List());
      });
    });
  }
}
