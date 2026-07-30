import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';

class ActivityLogHelper {
  static Future<void> logAndReward(BuildContext context, ActivityLog log) async {
    await context.read<ActivityProvider>().addLog(
          babyId: log.babyId,
          type: log.type,
          timestamp: log.timestamp,
          data: log.data,
          note: log.note,
        );
    await context.read<ShopProvider>().rewardForLogActivity();
    if (context.mounted) Navigator.pop(context);
  }
}

class FeedingScreen extends StatefulWidget {
  final bool isPump;

  const FeedingScreen({super.key, this.isPump = false});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  FeedingType _type = FeedingType.formula;
  final _amountCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '15');
  final _noteCtrl = TextEditingController();
  DateTime _time = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.isPump) _type = FeedingType.pump;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _durationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().activeBaby;
    if (baby == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        babyId: baby.id,
        type: ActivityType.feeding,
        timestamp: _time,
        data: {
          'feedingType': _type.name,
          'amount': double.tryParse(_amountCtrl.text) ?? 0,
          'durationMinutes': int.tryParse(_durationCtrl.text) ?? 15,
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'feedingTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        Text(AppStrings.t(context, 'feedingType'), style: AppTypography.labelBold()),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: FeedingType.values.map((t) {
            final label = switch (t) {
              FeedingType.breast => AppStrings.t(context, 'feedingBreast'),
              FeedingType.formula => AppStrings.t(context, 'feedingFormula'),
              FeedingType.pump => AppStrings.t(context, 'feedingPump'),
            };
            return ChoiceChip(
              label: Text(label),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amountCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'amount')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _durationCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'duration')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'note')),
        ),
      ],
    );
  }
}
