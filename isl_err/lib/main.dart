import 'package:flutter/material.dart';
import 'package:isl_err/app_theme.dart';

void main() {
  runApp(ISLBridgeApp());
}

/// Main App that manages theme switching.
class ISLBridgeApp extends StatefulWidget {
  @override
  _ISLBridgeAppState createState() => _ISLBridgeAppState();
}

class _ISLBridgeAppState extends State<ISLBridgeApp> {
  // We'll use a ValueNotifier to manage our current ThemeData.
  ValueNotifier<ThemeData> currentTheme = ValueNotifier(AppTheme.lightTheme);

  // Toggle between light and dark themes.
  void toggleTheme() {
    if (currentTheme.value.brightness == Brightness.light) {
      currentTheme.value = AppTheme.darkTheme;
    } else {
      currentTheme.value = AppTheme.lightTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: currentTheme,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'ISL Bridge',
          theme: theme,
          debugShowCheckedModeBanner: false,
          home: HomeScreen(
            onThemeToggle: toggleTheme,
            isDarkMode: theme.brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}