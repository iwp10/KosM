import 'package:flutter/material.dart';

import 'core/theme/theme.dart';
import 'core/theme/theme_preview_page.dart';

/// Root Application Widget for KosM.
class KosMApp extends StatefulWidget {
  const KosMApp({super.key});

  @override
  State<KosMApp> createState() => _KosMAppState();
}

class _KosMAppState extends State<KosMApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: ThemePreviewPage(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
