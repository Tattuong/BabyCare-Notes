import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFF1F5F9),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              tertiary: AppColors.accent,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
            ),
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.15)),
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.pastelTealDark,
    primaryLight: AppColors.pastelTeal,
    background: AppColors.background,
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkCard,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset blossom = AppThemePreset(
    id: 'theme_blossom',
    primary: Color(0xFFE895A0),
    primaryLight: Color(0xFFFADADD),
    background: Color(0xFFFFF8F9),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A1520),
    darkSurface: Color(0xFF3D2230),
    headerGradient: LinearGradient(colors: [Color(0xFFFADADD), Color(0xFFE895A0)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFFADADD), Color(0xFFF5B8C0)]),
  );

  static const AppThemePreset mint = AppThemePreset(
    id: 'theme_mint',
    primary: Color(0xFF5EC4A8),
    primaryLight: Color(0xFF88D8C0),
    background: Color(0xFFF5FFFB),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0F2A22),
    darkSurface: Color(0xFF1A3D32),
    headerGradient: LinearGradient(colors: [Color(0xFF88D8C0), Color(0xFF5EC4A8)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF88D8C0), Color(0xFF5EC4A8)]),
  );

  static const AppThemePreset lavender = AppThemePreset(
    id: 'theme_lavender',
    primary: Color(0xFFB39DDB),
    primaryLight: Color(0xFFD1C4E9),
    background: Color(0xFFF8F5FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF1E1033),
    darkSurface: Color(0xFF2E1A47),
    headerGradient: LinearGradient(colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFB39DDB), Color(0xFF9575CD)]),
  );

  static const AppThemePreset sunset = AppThemePreset(
    id: 'theme_sunset',
    primary: Color(0xFFFFB347),
    primaryLight: Color(0xFFFFD093),
    background: Color(0xFFFFF9F0),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A1F0F),
    darkSurface: Color(0xFF3D2E18),
    headerGradient: LinearGradient(colors: [Color(0xFFFFD093), Color(0xFFFFB347)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFFFB347), Color(0xFFFF8C42)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_blossom': blossom,
    'theme_mint': mint,
    'theme_lavender': lavender,
    'theme_sunset': sunset,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const AppBackground defaultBg = AppBackground(
    id: 'bg_default',
    gradient: AppColors.accentGradient,
  );

  static const AppBackground clouds = AppBackground(
    id: 'bg_clouds',
    gradient: LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFFADADD), Color(0xFF88D8C0)]),
  );

  static const AppBackground stars = AppBackground(
    id: 'bg_stars',
    gradient: LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF4338CA), Color(0xFF818CF8)]),
  );

  static const AppBackground rainbow = AppBackground(
    id: 'bg_rainbow',
    gradient: LinearGradient(colors: [Color(0xFFFADADD), Color(0xFFFFD093), Color(0xFF88D8C0), Color(0xFFB39DDB)]),
  );

  static const AppBackground bubbles = AppBackground(
    id: 'bg_bubbles',
    gradient: LinearGradient(colors: [Color(0xFF88D8C0), Color(0xFF74B9FF), Color(0xFFFADADD)]),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_clouds': clouds,
    'bg_stars': stars,
    'bg_rainbow': rainbow,
    'bg_bubbles': bubbles,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const CardStyle({
    required this.id,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  static const CardStyle defaultStyle = CardStyle(id: 'skin_default');

  static const CardStyle soft = CardStyle(
    id: 'skin_soft',
    borderRadius: 28,
    borderWidth: 0,
    accentColor: AppColors.pastelPink,
  );

  static const CardStyle cute = CardStyle(
    id: 'skin_cute',
    borderRadius: 24,
    borderWidth: 2,
    borderColor: AppColors.pastelPinkDark,
    accentColor: AppColors.pastelPinkDark,
  );

  static const CardStyle playful = CardStyle(
    id: 'skin_playful',
    borderRadius: 20,
    borderWidth: 2,
    borderColor: AppColors.pastelTeal,
    accentColor: AppColors.pastelTealDark,
    glassEffect: true,
  );

  static const Map<String, CardStyle> byId = {
    'skin_default': defaultStyle,
    'skin_soft': soft,
    'skin_cute': cute,
    'skin_playful': playful,
  };

  static CardStyle get(String? id) => byId[id] ?? defaultStyle;
}
