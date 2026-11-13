import 'package:flutter/material.dart';

/// Tema visual de KeepInventory (colores, tipografía, botones, tarjetas, formularios).
class AppTheme {
  static const Color primary = Color(0xFF1E3A5F); // azul marino
  static const Color accent = Color(0xFFF2A541); // ámbar
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      secondary: accent,
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: b == Brightness.light
          ? const Color(0xFFF5F7FA)
          : scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16),
        bodySmall: TextStyle(fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.black,
      ),
    );
  }

  /// Espaciados estándar.
  static const double gap = 16;
  static const double gapSmall = 8;
}
