import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/home_page.dart';

/// The opening screen is the native launch screen only (animated wordmark,
/// see `tool/splash_wordmark/`); the app opens straight to [HomePage].
class AlgoritiqApp extends StatelessWidget {
  const AlgoritiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlgoritiQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
