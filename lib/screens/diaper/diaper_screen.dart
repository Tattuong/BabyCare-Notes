import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/baby_provider.dart';
import '../feeding/feeding_screen.dart' show ActivityLogHelper;
import '../../widgets/app_ui.dart';

class DiaperScreen extends StatefulWidget {
  const DiaperScreen({super.key});

  @override
  State<DiaperScreen> createState() => _DiaperScreenState();
}

class _DiaperScreenState extends State<DiaperScreen> {
  DiaperType _type = DiaperType.wet;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
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
        type: ActivityType.diaper,
        timestamp: DateTime.now(),
        data: {'diaperType': _type.name},
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'diaperTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        Wrap(
          spacing: 8,
          children: DiaperType.values.map((t) {
            final label = switch (t) {
              DiaperType.wet => AppStrings.t(context, 'diaperWet'),
              DiaperType.dirty => AppStrings.t(context, 'diaperDirty'),
              DiaperType.both => AppStrings.t(context, 'diaperBoth'),
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
          controller: _noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'note')),
        ),
      ],
    );
  }
}
