import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../widgets/app_ui.dart';

class TimelineScreen extends StatefulWidget {
  final bool embedded;

  const TimelineScreen({super.key, this.embedded = false});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final _searchCtrl = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(BuildContext context, ActivityType type) => switch (type) {
        ActivityType.feeding => AppStrings.t(context, 'feeding'),
        ActivityType.sleep => AppStrings.t(context, 'sleep'),
        ActivityType.diaper => AppStrings.t(context, 'diaper'),
        ActivityType.growth => AppStrings.t(context, 'growth'),
        ActivityType.memory => AppStrings.t(context, 'milestones'),
        ActivityType.vaccine => AppStrings.t(context, 'vaccine'),
        ActivityType.note => AppStrings.t(context, 'notebook'),
      };

  IconData _typeIcon(ActivityType type) => switch (type) {
        ActivityType.feeding => Icons.local_drink_outlined,
        ActivityType.sleep => Icons.nightlight_round,
        ActivityType.diaper => Icons.baby_changing_station_outlined,
        ActivityType.growth => Icons.show_chart_outlined,
        ActivityType.memory => Icons.emoji_events_outlined,
        ActivityType.vaccine => Icons.vaccines_outlined,
        ActivityType.note => Icons.edit_note_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().activeBaby;
    final activity = context.watch<ActivityProvider>();

    if (baby == null) return const SizedBox.shrink();

    var logs = activity.logsForBaby(baby.id);
    if (_selectedDate != null) {
      logs = activity.logsForDate(baby.id, _selectedDate!);
    } else if (_searchCtrl.text.isNotEmpty) {
      logs = activity.searchLogs(baby.id, _searchCtrl.text);
    }

    return AppPageScaffold(
      embedded: widget.embedded,
      title: AppStrings.t(context, 'timeline'),
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() => _selectedDate = null),
          decoration: InputDecoration(
            hintText: AppStrings.t(context, 'search'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: baby.birthDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (logs.isEmpty)
          AppEmptyState(
            icon: Icons.timeline,
            message: AppStrings.t(context, 'noLogs'),
          )
        else
          ...logs.map((log) {
            final fmt = DateFormat('dd/MM/yyyy HH:mm');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppGlassCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.pastelTeal.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_typeIcon(log.type), size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_typeLabel(context, log.type), style: AppTypography.labelBold(size: 14)),
                          Text(fmt.format(log.timestamp), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          if (log.note != null && log.note!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(log.note!, style: const TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      onPressed: () => activity.deleteLog(log.id),
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
