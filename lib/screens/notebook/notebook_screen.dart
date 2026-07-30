import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/baby_provider.dart';
import '../feeding/feeding_screen.dart' show ActivityLogHelper;
import '../../widgets/app_ui.dart';

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().activeBaby;
    if (baby == null || _noteCtrl.text.trim().isEmpty) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        babyId: baby.id,
        type: ActivityType.note,
        timestamp: DateTime.now(),
        data: const {},
        note: _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'notebook'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        TextField(
          controller: _noteCtrl,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: AppStrings.t(context, 'notes'),
            hintText: AppStrings.t(context, 'appTagline'),
          ),
        ),
      ],
    );
  }
}
