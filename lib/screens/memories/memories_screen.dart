import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/baby_provider.dart';
import '../../providers/shop_provider.dart';
import '../feeding/feeding_screen.dart' show ActivityLogHelper;
import '../../widgets/app_ui.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  MilestoneType _milestone = MilestoneType.firstSmile;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _milestoneLabel(BuildContext context, MilestoneType t) => switch (t) {
        MilestoneType.firstSmile => AppStrings.t(context, 'milestoneFirstSmile'),
        MilestoneType.rollOver => AppStrings.t(context, 'milestoneRollOver'),
        MilestoneType.sitUp => AppStrings.t(context, 'milestoneSitUp'),
        MilestoneType.crawl => AppStrings.t(context, 'milestoneCrawl'),
        MilestoneType.stand => AppStrings.t(context, 'milestoneStand'),
        MilestoneType.walk => AppStrings.t(context, 'milestoneWalk'),
        MilestoneType.firstWord => AppStrings.t(context, 'milestoneFirstWord'),
        MilestoneType.other => AppStrings.t(context, 'milestoneOther'),
      };

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().activeBaby;
    if (baby == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        babyId: baby.id,
        type: ActivityType.memory,
        timestamp: DateTime.now(),
        data: {'milestone': _milestone.name},
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
    await context.read<ShopProvider>().rewardForMilestone();
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'memoriesTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        Text(AppStrings.t(context, 'milestone'), style: AppTypography.labelBold()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: MilestoneType.values.map((t) {
            return ChoiceChip(
              label: Text(_milestoneLabel(context, t)),
              selected: _milestone == t,
              onSelected: (_) => setState(() => _milestone = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _noteCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: AppStrings.t(context, 'notes'),
            hintText: AppStrings.t(context, 'appTagline'),
          ),
        ),
      ],
    );
  }
}
