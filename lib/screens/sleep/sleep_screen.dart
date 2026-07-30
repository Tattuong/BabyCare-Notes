import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/baby_provider.dart';
import '../feeding/feeding_screen.dart' show ActivityLogHelper;
import '../../widgets/app_ui.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  DateTime _start = DateTime.now().subtract(const Duration(hours: 2));
  DateTime _end = DateTime.now();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _start : _end;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null) return;
    setState(() {
      final dt = DateTime(initial.year, initial.month, initial.day, time.hour, time.minute);
      if (isStart) {
        _start = dt;
      } else {
        _end = dt;
      }
    });
  }

  String _formatDuration() {
    final mins = _end.difference(_start).inMinutes.abs();
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  Future<void> _save() async {
    final baby = context.read<BabyProvider>().activeBaby;
    if (baby == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        babyId: baby.id,
        type: ActivityType.sleep,
        timestamp: _end,
        data: {
          'start': _start.toIso8601String(),
          'end': _end.toIso8601String(),
          'durationMinutes': _end.difference(_start).inMinutes.abs(),
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'sleepTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t(context, 'sleepStart')),
          subtitle: Text('${_start.hour.toString().padLeft(2, '0')}:${_start.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _pickTime(true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t(context, 'sleepEnd')),
          subtitle: Text('${_end.hour.toString().padLeft(2, '0')}:${_end.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.access_time),
          onTap: () => _pickTime(false),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.t(context, 'sleepTotal', {'duration': _formatDuration()}),
          style: AppTypography.labelBold(color: Theme.of(context).colorScheme.primary),
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
