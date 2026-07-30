import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../models/baby.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/home_style.dart';
import '../diaper/diaper_screen.dart';
import '../feeding/feeding_screen.dart';
import '../growth/growth_screen.dart';
import '../memories/memories_screen.dart';
import '../notebook/notebook_screen.dart';
import '../sleep/sleep_screen.dart';
import '../vaccine/vaccine_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final vi = AppStrings.languageCodeOf(context) == 'vi';
    final baby = context.select<BabyProvider, Baby?>((p) => p.activeBaby);

    if (baby == null) {
      return ColoredBox(
        color: HomeStyle.pageBg,
        child: Center(
          child: _EmptyBabyPrompt(onAdd: () => _showAddBabyDialog(context)),
        ),
      );
    }

    final babies = context.select<BabyProvider, List<Baby>>((p) => p.babies);
    final canAdd = context.select<ShopProvider, bool>((s) => s.canAddMoreBabies(babies.length));

    return ColoredBox(
      color: HomeStyle.pageBg,
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _BabyTabs(
              babies: babies,
              activeId: baby.id,
              canAdd: canAdd,
              onSelect: context.read<BabyProvider>().selectBaby,
              onAdd: () => _showAddBabyDialog(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: _BabyAvatar(
                baby: baby,
                ageLabel: baby.ageLabel(vi: vi),
                onEdit: () => _showEditBabyDialog(context, baby),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: _HomeActivityGrid(
                  babyId: baby.id,
                  vi: vi,
                  onOpen: _openScreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddBabyDialog(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    final babyProvider = context.read<BabyProvider>();
    if (!shop.canAddMoreBabies(babyProvider.babies.length)) {
      final openShop = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.t(context, 'addBaby')),
          content: Text(AppStrings.t(context, 'multiBabyLocked')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppStrings.t(context, 'navShop')),
            ),
          ],
        ),
      );
      if (openShop == true && context.mounted) {
        MainShell.instance?.openShop();
      }
      return;
    }

    final result = await showDialog<({String name, DateTime birthDate})>(
      context: context,
      builder: (ctx) => const _BabyFormDialog(isEdit: false),
    );
    if (result != null && context.mounted) {
      await babyProvider.addBaby(name: result.name, birthDate: result.birthDate);
    }
  }

  Future<void> _showEditBabyDialog(BuildContext context, Baby baby) async {
    final result = await showDialog<({String name, DateTime birthDate})>(
      context: context,
      builder: (ctx) => _BabyFormDialog(isEdit: true, initialName: baby.name, initialBirthDate: baby.birthDate),
    );
    if (result != null && context.mounted) {
      await context.read<BabyProvider>().updateBaby(
            baby.copyWith(name: result.name, birthDate: result.birthDate),
          );
    }
  }
}

class _BabyFormDialog extends StatefulWidget {
  final bool isEdit;
  final String? initialName;
  final DateTime? initialBirthDate;

  const _BabyFormDialog({
    required this.isEdit,
    this.initialName,
    this.initialBirthDate,
  });

  @override
  State<_BabyFormDialog> createState() => _BabyFormDialogState();
}

class _BabyFormDialogState extends State<_BabyFormDialog> {
  late final TextEditingController _nameCtrl;
  late DateTime _birthDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _birthDate = widget.initialBirthDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name: name, birthDate: _birthDate));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.t(context, widget.isEdit ? 'editBaby' : 'addBaby')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: !widget.isEdit,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'babyName')),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.t(context, 'birthDate')),
              subtitle: Text(_formatDate(_birthDate)),
              trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryDark),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _birthDate,
                  firstDate: DateTime(2018),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t(context, 'cancel'))),
        FilledButton(onPressed: _save, child: Text(AppStrings.t(context, 'save'))),
      ],
    );
  }
}

class _EmptyBabyPrompt extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyBabyPrompt({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: HomeStyle.circleGradient(true),
              boxShadow: HomeStyle.softShadow(HomeStyle.circlePinkDeep),
            ),
            child: const Icon(Icons.child_care_rounded, size: 44, color: HomeStyle.iconInk),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.t(context, 'addBaby'), style: HomeStyle.gridLabel()),
          const SizedBox(height: 16),
          FilledButton(onPressed: onAdd, child: Text(AppStrings.t(context, 'getStarted'))),
        ],
      ),
    );
  }
}

class _BabyTabs extends StatelessWidget {
  final List<Baby> babies;
  final String activeId;
  final bool canAdd;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  const _BabyTabs({
    required this.babies,
    required this.activeId,
    required this.canAdd,
    required this.onSelect,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...babies.map((b) {
                    final active = b.id == activeId;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelect(b.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                            decoration: HomeStyle.tabDecoration(active: active),
                            child: Text(b.name, style: HomeStyle.tabLabel(active: active)),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Material(
            color: canAdd ? AppColors.primaryDark : AppColors.textMuted.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(24),
            elevation: canAdd ? 2 : 0,
            shadowColor: AppColors.primaryDark.withValues(alpha: 0.35),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                HapticFeedback.lightImpact();
                onAdd();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                child: Icon(
                  canAdd ? Icons.add_rounded : Icons.lock_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BabyAvatar extends StatelessWidget {
  final Baby baby;
  final String ageLabel;
  final VoidCallback onEdit;

  const _BabyAvatar({required this.baby, required this.ageLabel, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 124,
          height: 124,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 124,
                height: 124,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.pastelPink, AppColors.pastelTeal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pastelTealDark.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  padding: const EdgeInsets.all(3),
                  child: ClipOval(
                    child: baby.photoPath != null
                        ? Image.file(
                            File(baby.photoPath!),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            cacheWidth: 248,
                            cacheHeight: 248,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) => _defaultAvatar(),
                          )
                        : _defaultAvatar(),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Material(
                  color: AppColors.primaryDark,
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: AppColors.primaryDark.withValues(alpha: 0.4),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onEdit();
                    },
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.pastelPink.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(ageLabel, style: HomeStyle.ageLabel()),
        ),
      ],
    );
  }

  Widget _defaultAvatar() => DecoratedBox(
        decoration: BoxDecoration(gradient: HomeStyle.circleGradient(true)),
        child: Center(
          child: Icon(Icons.child_care_rounded, size: 52, color: AppColors.primaryDark.withValues(alpha: 0.75)),
        ),
      );
}

class _HomeActivityGrid extends StatelessWidget {
  final String babyId;
  final bool vi;
  final void Function(Widget screen) onOpen;

  const _HomeActivityGrid({
    required this.babyId,
    required this.vi,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<ActivityProvider, int>(
      selector: (_, p) => Object.hash(
        p.lastLog(babyId, ActivityType.feeding)?.timestamp.millisecondsSinceEpoch,
        p.lastLog(babyId, ActivityType.sleep)?.timestamp.millisecondsSinceEpoch,
        p.lastLog(babyId, ActivityType.diaper)?.timestamp.millisecondsSinceEpoch,
        p.lastLog(babyId, ActivityType.growth)?.timestamp.millisecondsSinceEpoch,
      ),
      builder: (context, _, __) {
        final activity = context.read<ActivityProvider>();
        final diaperDue = _diaperDue(activity, babyId);
        final diaperBadge = diaperDue
            ? AppStrings.t(context, 'itsTime')
            : _timeAgo(activity, babyId, ActivityType.diaper, vi);

        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
          children: [
            _ActivityTile(
              label: AppStrings.t(context, 'feeding'),
              icon: Icons.local_drink_rounded,
              isPink: true,
              badge: _timeAgo(activity, babyId, ActivityType.feeding, vi),
              onTap: () => onOpen(const FeedingScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'sleep'),
              icon: Icons.bedtime_rounded,
              isPink: true,
              badge: _timeAgo(activity, babyId, ActivityType.sleep, vi),
              onTap: () => onOpen(const SleepScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'pump'),
              icon: Icons.water_drop_rounded,
              isPink: true,
              badge: _timeAgo(activity, babyId, ActivityType.feeding, vi),
              onTap: () => onOpen(const FeedingScreen(isPump: true)),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'diaper'),
              icon: Icons.baby_changing_station_rounded,
              isPink: true,
              badge: diaperBadge,
              highlightBadge: diaperDue,
              showBell: diaperDue,
              onTap: () => onOpen(const DiaperScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'height'),
              icon: Icons.straighten_rounded,
              isPink: true,
              badge: _timeAgo(activity, babyId, ActivityType.growth, vi),
              onTap: () => onOpen(const GrowthScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'vaccine'),
              icon: Icons.vaccines_rounded,
              isPink: false,
              onTap: () => onOpen(const VaccineScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'milestones'),
              icon: Icons.emoji_events_rounded,
              isPink: false,
              onTap: () => onOpen(const MemoriesScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'growth'),
              icon: Icons.show_chart_rounded,
              isPink: false,
              onTap: () => onOpen(const GrowthScreen()),
            ),
            _ActivityTile(
              label: AppStrings.t(context, 'notebook'),
              icon: Icons.edit_note_rounded,
              isPink: false,
              onTap: () => onOpen(const NotebookScreen()),
            ),
          ],
        );
      },
    );
  }

  String? _timeAgo(ActivityProvider provider, String babyId, ActivityType type, bool vi) {
    final last = provider.lastLog(babyId, type);
    if (last == null) return null;
    return provider.timeAgoLabel(last.timestamp, vi: vi);
  }

  bool _diaperDue(ActivityProvider provider, String babyId) {
    final last = provider.lastLog(babyId, ActivityType.diaper);
    if (last == null) return true;
    return DateTime.now().difference(last.timestamp).inHours >= 3;
  }
}

class _ActivityTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPink;
  final String? badge;
  final bool highlightBadge;
  final bool showBell;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.label,
    required this.icon,
    required this.isPink,
    this.badge,
    this.highlightBadge = false,
    this.showBell = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = isPink ? HomeStyle.circlePinkDeep : HomeStyle.circleTealDeep;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(40),
        splashColor: AppColors.primaryDark.withValues(alpha: 0.08),
        highlightColor: AppColors.primaryDark.withValues(alpha: 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              child: badge != null
                  ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 96),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  badge!,
                                  style: HomeStyle.badgeText(highlight: highlightBadge),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (showBell) ...[
                                const SizedBox(width: 3),
                                Icon(
                                  Icons.notifications_active_rounded,
                                  size: 11,
                                  color: highlightBadge ? AppColors.primaryDark : HomeStyle.iconInk,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: HomeStyle.circleGradient(isPink),
                boxShadow: HomeStyle.softShadow(shadowColor),
              ),
              child: Center(
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                  child: Icon(icon, size: 28, color: HomeStyle.iconInk.withValues(alpha: 0.82)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: HomeStyle.gridLabel(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
