import 'package:flutter/material.dart';

class AppTheme {
  // Neutral color palette
  static const Color _neutralGray = Color(0xFFF5F7FA);
  static const Color _deepBlue = Color(0xFF2C3E50);
  static const Color _subtleAccent = Color(0xFF3498DB);

  /// Refined Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: _neutralGray,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: _deepBlue),
      titleTextStyle: TextStyle(
        color: _deepBlue,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: _deepBlue,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: _deepBlue,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: _deepBlue,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF4A5568),
        fontSize: 16,
        letterSpacing: 0.1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _subtleAccent,
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
  );

  /// Refined Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: const Color(0xFF1A202C),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A202C),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.grey[100],
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: Colors.grey[100],
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: Colors.grey[100],
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: Colors.grey[200],
        fontSize: 18,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
      bodyLarge: TextStyle(
        color: Colors.grey[300],
        fontSize: 16,
        letterSpacing: 0.1,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF2D3748),
    ),
  );

  /// Accessible Light Theme
  static final ThemeData accessibleLight = lightTheme.copyWith(
    textTheme: lightTheme.textTheme.apply(
      fontSizeFactor: 1.1,
      fontSizeDelta: 2.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );

  /// Accessible Dark Theme
  static final ThemeData accessibleDark = darkTheme.copyWith(
    textTheme: darkTheme.textTheme.apply(
      fontSizeFactor: 1.1,
      fontSizeDelta: 2.0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}
