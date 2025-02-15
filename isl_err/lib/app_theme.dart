import 'package:flutter/material.dart';

class AppTheme {
  /// Standard Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      displaySmall: TextStyle(color: Colors.black, fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 16)),
    ),
  );

  /// Standard Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey[900],
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(color: Colors.white, fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 16)),
    ),
  );

  /// High Contrast Light Theme – Enhances visibility for low-vision users
  static final ThemeData highContrastLight = lightTheme.copyWith(
    textTheme: lightTheme.textTheme.apply(
      bodyColor: Colors.black,
      displayColor: Colors.black,
      fontSizeFactor: 1.1, // Slightly larger text
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    // Optionally, adjust other elements for higher contrast.
    colorScheme: lightTheme.colorScheme.copyWith(
      secondary: Colors.black, // Use a darker secondary color if needed.
    ),
  );

  /// High Contrast Dark Theme – Enhances visibility for low-vision users
  static final ThemeData highContrastDark = darkTheme.copyWith(
    textTheme: darkTheme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
      fontSizeFactor: 1.1, // Slightly larger text
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
    // Optionally, adjust other elements for higher contrast.
    colorScheme: darkTheme.colorScheme.copyWith(
      secondary: Colors.white, // Use a lighter secondary color if needed.
    ),
  );
}
