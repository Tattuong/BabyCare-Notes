import 'package:flutter/material.dart';

/// Pastel baby-care palette inspired by the reference design.
class AppColors {
  static const Color pastelPink = Color(0xFFFADADD);
  static const Color pastelPinkDark = Color(0xFFF5B8C0);
  static const Color pastelTeal = Color(0xFF88D8C0);
  static const Color pastelTealDark = Color(0xFF5EC4A8);

  static const Color primary = pastelTealDark;
  static const Color primaryLight = pastelTeal;
  static const Color primaryDark = Color(0xFF3BA88A);

  static const Color accent = pastelPinkDark;
  static const Color accentAlt = pastelPink;

  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textMuted = Color(0xFF95A5A6);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8F9FA);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF2D3436);
  static const Color onSurfaceVariant = Color(0xFF636E72);

  static const Color success = Color(0xFF55C595);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color coin = Color(0xFFFFD93D);

  static const Color trueBlack = Color(0xFF1A1A2E);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF252542);
  static const Color darkCard = Color(0xFF2D2D4A);
  static const Color darkNavBar = Color(0xFF252542);

  static const Color magenta = pastelPinkDark;
  static const Color magentaDark = Color(0xFFE895A0);
  static const Color magentaSoft = pastelPink;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelTeal, pastelTealDark],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelPink, pastelPinkDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pastelTeal, pastelPink],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFADADD), Color(0xFF88D8C0), Color(0xFF5EC4A8)],
  );

  static const List<Color> categoryPalette = [
    pastelPinkDark,
    pastelTealDark,
    Color(0xFFFFB347),
    Color(0xFFA29BFE),
    Color(0xFF74B9FF),
    Color(0xFFFD79A8),
    Color(0xFF55C595),
    Color(0xFF636E72),
  ];

  static Color circleColor(bool isPink) => isPink ? pastelPink : pastelTeal;
}
