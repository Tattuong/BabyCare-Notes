import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/shop_provider.dart';
import '../feeding/feeding_screen.dart' show ActivityLogHelper;
import '../../widgets/app_ui.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _headCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _headCtrl.dispose();
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
        type: ActivityType.growth,
        timestamp: DateTime.now(),
        data: {
          'height': double.tryParse(_heightCtrl.text),
          'weight': double.tryParse(_weightCtrl.text),
          'head': double.tryParse(_headCtrl.text),
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baby = context.watch<BabyProvider>().activeBaby;
    final shop = context.watch<ShopProvider>();
    final activity = context.watch<ActivityProvider>();
    final growthData = baby != null ? activity.growthData(baby.id) : <Map<String, dynamic>>[];

    return AppFormScreen(
      title: AppStrings.t(context, 'growthTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        TextField(
          controller: _heightCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'height')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weightCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'weight')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _headCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'headCircumference')),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'note')),
        ),
        if (growthData.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(AppStrings.t(context, 'growthChart'), style: AppTypography.labelBold(size: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: shop.hasGrowthPro
                ? _GrowthChart(data: growthData, showAdvanced: true)
                : _GrowthChart(data: growthData, showAdvanced: false),
          ),
          if (!shop.hasGrowthPro)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                AppStrings.t(context, 'growthProLocked'),
                style: const TextStyle(fontSize: 11, color: AppColors.warning),
              ),
            ),
        ],
      ],
    );
  }
}

class _GrowthChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool showAdvanced;

  const _GrowthChart({required this.data, required this.showAdvanced});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final w = data[i]['weight'] as double?;
      if (w != null) spots.add(FlSpot(i.toDouble(), w));
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: showAdvanced),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: showAdvanced, reservedSize: 32)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: showAdvanced)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: showAdvanced),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(show: showAdvanced),
          ),
        ],
      ),
    );
  }
}
