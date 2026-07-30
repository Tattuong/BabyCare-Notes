import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class HomeStyle {
  HomeStyle._();

  static const Color pageBg = Color(0xFFFAFCFB);
  static const Color circlePink = Color(0xFFFADADD);
  static const Color circlePinkDeep = Color(0xFFF5C6CF);
  static const Color circleTeal = Color(0xFFC8EBDF);
  static const Color circleTealDeep = Color(0xFFA8DFCB);
  static const Color tabInactiveFill = Color(0xFFE6F5EF);
  static const Color iconInk = Color(0xFF3D5A54);

  static final TextStyle tabLabelActive = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
    letterSpacing: 0.2,
  );

  static final TextStyle tabLabelInactive = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF5A7A72),
    letterSpacing: 0.2,
  );

  static final TextStyle gridLabelStyle = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
    letterSpacing: 0.15,
  );

  static final TextStyle ageLabelStyle = GoogleFonts.nunito(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AppColors.pastelPinkDark,
    letterSpacing: 0.3,
  );

  static final TextStyle badgeTextNormal = GoogleFonts.nunito(
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF6B8A82),
    letterSpacing: 0.1,
  );

  static final TextStyle badgeTextHighlight = GoogleFonts.nunito(
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
    letterSpacing: 0.1,
  );

  static TextStyle tabLabel({required bool active}) => active ? tabLabelActive : tabLabelInactive;

  static TextStyle gridLabel() => gridLabelStyle;

  static TextStyle ageLabel() => ageLabelStyle;

  static TextStyle badgeText({bool highlight = false}) =>
      highlight ? badgeTextHighlight : badgeTextNormal;

  static List<BoxShadow> softShadow(Color c) => [
        BoxShadow(color: c.withValues(alpha: 0.22), blurRadius: 10, offset: const Offset(0, 4)),
      ];

  static const LinearGradient circlePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDF0F2), circlePink, circlePinkDeep],
  );

  static const LinearGradient circleTealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEFAF5), circleTeal, circleTealDeep],
  );

  static LinearGradient circleGradient(bool isPink) => isPink ? circlePinkGradient : circleTealGradient;

  static BoxDecoration tabDecoration({required bool active}) => BoxDecoration(
        color: active ? Colors.white : tabInactiveFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? AppColors.pastelTeal.withValues(alpha: 0.55) : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      );
}

class CubsNavIcon extends StatelessWidget {
  final Color color;
  final double size;

  const CubsNavIcon({super.key, required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final dot = size * 0.22;
    final gap = size * 0.11;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_dot(dot, color), SizedBox(width: gap), _dot(dot, color)],
          ),
          SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_dot(dot, color), SizedBox(width: gap), _dot(dot, color)],
          ),
        ],
      ),
    );
  }

  Widget _dot(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );
}
