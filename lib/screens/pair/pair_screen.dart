import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/app_ui.dart';

class PairScreen extends StatelessWidget {
  final bool embedded;

  const PairScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      embedded: embedded,
      title: AppStrings.t(context, 'navPair'),
      subtitle: AppStrings.t(context, 'pairSubtitle'),
      children: [
        AppGlassCard(
          child: Column(
            children: [
              Icon(Icons.phonelink_ring_outlined, size: 56, color: AppColors.primaryDark.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(
                AppStrings.t(context, 'pairDesc'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(AppStrings.t(context, 'pairScan')),
        ),
      ],
    );
  }
}
