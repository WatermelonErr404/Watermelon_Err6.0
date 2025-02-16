// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:isl_application/screens/splash_screen.dart';
import 'package:isl_application/theme/app_theme.dart';

void main() {
  runApp(const ISLBridgeApp());
}

class ISLBridgeApp extends StatefulWidget {
  const ISLBridgeApp({super.key});

  @override
  _ISLBridgeAppState createState() => _ISLBridgeAppState();
}

class _ISLBridgeAppState extends State<ISLBridgeApp> {
  final ValueNotifier<ThemeData> currentTheme =
      ValueNotifier(AppTheme.lightTheme);

  void toggleTheme() {
    if (currentTheme.value.brightness == Brightness.light) {
      currentTheme.value = AppTheme.darkTheme;
    } else {
      currentTheme.value = AppTheme.lightTheme;
    }
  }

  bool get isDarkMode => currentTheme.value.brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'SIGNIFY',
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: SplashScreen(
            toggleTheme: toggleTheme,
          ),
        );
      },
    );
  }
}
