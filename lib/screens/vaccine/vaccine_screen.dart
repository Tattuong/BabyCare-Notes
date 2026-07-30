import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';

class VaccineScreen extends StatelessWidget {
  const VaccineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().activeBaby;
    final activity = context.watch<ActivityProvider>();
    final shop = context.watch<ShopProvider>();

    if (baby == null) return const SizedBox.shrink();

    final schedule = activity.vaccineSchedule(baby.id);

    return AppPageScaffold(
      title: AppStrings.t(context, 'vaccineTitle'),
      subtitle: shop.hasVaccineReminder
          ? AppStrings.t(context, 'vaccineReminder')
          : AppStrings.t(context, 'vaccineReminderLocked'),
      children: [
        ...schedule.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppGlassCard(
              onTap: () => activity.toggleVaccine(baby.id, v.id),
              child: Row(
                children: [
                  Icon(
                    v.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: v.completed ? AppColors.success : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(v.name, style: AppTypography.labelBold(size: 14)),
                        Text(
                          '${v.recommendedWeeks} ${AppStrings.languageCodeOf(context) == 'vi' ? 'tuần' : 'weeks'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (v.completed)
                    Text(
                      AppStrings.t(context, 'vaccineDone'),
                      style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                    )
                  else
                    Text(
                      AppStrings.t(context, 'vaccineDue'),
                      style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600),
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
