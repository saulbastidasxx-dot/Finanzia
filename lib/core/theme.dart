import 'package:flutter/material.dart';

class FinanziaTheme {
  static const navy = Color(0xFF0A315B);
  static const blue = Color(0xFF1677FF);
  static const green = Color(0xFF18C98B);
  static const coral = Color(0xFFFF6474);
  static ThemeData get light => _base(
    Brightness.light,
    const Color(0xFFF5F8FC),
    Colors.white,
    const Color(0xFF132238),
  );
  static ThemeData get dark => _base(
    Brightness.dark,
    const Color(0xFF071522),
    const Color(0xFF102333),
    const Color(0xFFF4F8FC),
  );
  static ThemeData _base(Brightness b, Color bg, Color card, Color fg) =>
      ThemeData(
        useMaterial3: true,
        brightness: b,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: b,
          surface: card,
        ),
        textTheme: Typography.material2021(platform: TargetPlatform.iOS).black
            .apply(bodyColor: fg, displayColor: fg),
        cardTheme: CardThemeData(
          color: card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: card,
          indicatorColor: blue.withValues(alpha: .14),
        ),
      );
}
