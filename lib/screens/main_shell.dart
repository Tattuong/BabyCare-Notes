import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/home_style.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';
import 'shop/shop_screen.dart';
import 'timeline/timeline_screen.dart';
import 'tips/tips_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static final GlobalKey<MainShellState> shellKey = GlobalKey<MainShellState>();

  static MainShellState? get instance => shellKey.currentState;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;

  void openShop({ShopRewardsTab tab = ShopRewardsTab.all}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopScreen(initialTab: tab)),
    );
  }

  void _onTabChanged(int i) {
    if (i == 3) {
      _openMore(context);
      return;
    }
    setState(() => _index = i);
  }

  void _openMore(BuildContext context, {ShopRewardsTab openShopTab = ShopRewardsTab.all}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.storefront_outlined, color: AppColors.primaryDark),
              title: Text(AppStrings.t(context, 'navShop'), style: HomeStyle.gridLabel()),
              onTap: () {
                Navigator.pop(ctx);
                openShop(tab: openShopTab);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primaryDark),
              title: Text(AppStrings.t(context, 'navSettings'), style: HomeStyle.gridLabel()),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int i) {
    return switch (i) {
      0 => const RepaintBoundary(child: HomeScreen()),
      1 => const TipsScreen(embedded: true),
      2 => const TimelineScreen(embedded: true),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeStyle.pageBg,
      body: SafeArea(
        bottom: false,
        child: TickerMode(
          enabled: true,
          child: _buildTab(_index),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onChanged: _onTabChanged,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _BottomNav({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const inactive = AppColors.textMuted;
    const active = AppColors.primaryDark;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 12, 12, bottom > 0 ? bottom : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            label: AppStrings.t(context, 'tabCubs'),
            active: index == 0,
            activeColor: active,
            inactiveColor: inactive,
            icon: CubsNavIcon(color: index == 0 ? active : inactive),
            onTap: () => onChanged(0),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navTips'),
            active: index == 1,
            activeColor: active,
            inactiveColor: inactive,
            icon: Icon(Icons.favorite_rounded, size: 24, color: index == 1 ? active : inactive),
            onTap: () => onChanged(1),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navLogs'),
            active: index == 2,
            activeColor: active,
            inactiveColor: inactive,
            icon: Icon(Icons.bar_chart_rounded, size: 24, color: index == 2 ? active : inactive),
            onTap: () => onChanged(2),
          ),
          _NavItem(
            label: AppStrings.t(context, 'navMore'),
            active: false,
            activeColor: active,
            inactiveColor: inactive,
            icon: Icon(Icons.more_horiz, size: 24, color: inactive),
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final Widget icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.pastelTeal.withValues(alpha: 0.22) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 4),
                Text(
                  label,
                  style: HomeStyle.badgeText(highlight: active).copyWith(
                    color: active ? activeColor : inactiveColor,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
