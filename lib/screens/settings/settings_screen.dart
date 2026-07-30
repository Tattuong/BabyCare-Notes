import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/activity_provider.dart';
import '../../providers/baby_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../main_shell.dart';
import '../privacy_policy_screen.dart';
import '../shop/shop_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool embedded;

  const SettingsScreen({super.key, this.embedded = false});

  void _openShop(BuildContext context, {ShopRewardsTab tab = ShopRewardsTab.all}) {
    if (!embedded) Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MainShell.instance?.openShop(tab: tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();

    final body = AppPageScaffold(
      embedded: embedded,
      title: AppStrings.t(context, 'settings'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: shop.isBillingDisabled ? null : () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        AppSectionHeader(AppStrings.t(context, 'darkMode'), icon: Icons.dark_mode_outlined),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppGlassCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(AppStrings.t(context, 'darkMode')),
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'language'), icon: Icons.language_outlined),
        AppSettingTile(
          icon: Icons.language_outlined,
          title: AppStrings.t(context, 'language'),
          subtitle: locale.isVietnamese ? 'Tiếng Việt' : 'English',
          onTap: () => _pickLanguage(context, locale),
        ),
        AppSectionHeader(AppStrings.t(context, 'navShop'), icon: Icons.storefront_outlined),
        AppSettingTile(
          icon: Icons.stars_rounded,
          title: AppStrings.t(context, 'navShop'),
          subtitle: '${shop.coins} ${AppStrings.t(context, 'coinsLabel')}',
          iconColor: AppColors.coin,
          onTap: () => _openShop(context),
        ),
        if (!shop.isBillingDisabled)
          AppSettingTile(
            icon: Icons.restore_outlined,
            title: 'Restore purchases',
            onTap: () async {
              await shop.billing.restorePurchases();
              if (context.mounted) AppToast.show(context, title: 'Restored');
            },
          ),
        AppSettingTile(
          icon: Icons.file_download_outlined,
          title: AppStrings.t(context, 'exportData'),
          subtitle: shop.hasExportData ? null : AppStrings.t(context, 'exportLocked'),
          onTap: shop.hasExportData ? () => _exportData(context) : () => _openShop(context, tab: ShopRewardsTab.features),
        ),
        AppSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: AppStrings.t(context, 'privacyPolicy'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
        ),
        AppSettingTile(
          icon: Icons.info_outline,
          title: AppStrings.t(context, 'about'),
          subtitle: '${AppStrings.t(context, 'version')} 1.0.0',
        ),
      ],
    );

    return body;
  }

  Future<void> _exportData(BuildContext context) async {
    final baby = context.read<BabyProvider>().activeBaby;
    if (baby == null) return;
    final payload = context.read<ActivityProvider>().exportData(baby.id);
    await Share.share(payload, subject: 'BabyCare Notes Export');
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'exportData'));
  }

  Future<void> _pickLanguage(BuildContext context, LocaleProvider locale) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: !locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                locale.setEnglish();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Tiếng Việt'),
              trailing: locale.isVietnamese ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                locale.setVietnamese();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
