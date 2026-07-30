import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/app_ui.dart';

class TipsScreen extends StatelessWidget {
  final bool embedded;

  const TipsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final tips = [
      ('tip1Title', 'tip1Body', Icons.bedtime_outlined, AppColors.pastelTeal),
      ('tip2Title', 'tip2Body', Icons.local_drink_outlined, AppColors.pastelPink),
      ('tip3Title', 'tip3Body', Icons.baby_changing_station_outlined, AppColors.pastelTealDark),
      ('tip4Title', 'tip4Body', Icons.vaccines_outlined, AppColors.warning),
      ('tip5Title', 'tip5Body', Icons.emoji_events_outlined, AppColors.accent),
    ];

    return AppPageScaffold(
      embedded: embedded,
      title: AppStrings.t(context, 'tipsTitle'),
      subtitle: AppStrings.t(context, 'appTagline'),
      children: [
        ...tips.map((t) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppGlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (t.$4 as Color).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(t.$3 as IconData, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t(context, t.$1), style: AppTypography.labelBold(size: 15)),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.t(context, t.$2),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
