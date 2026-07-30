import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/baby_provider.dart';
import '../widgets/app_ui.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  final _nameCtrl = TextEditingController();
  int _page = 0;
  DateTime _birthDate = DateTime.now();

  static const _pages = [
    (Icons.child_care, 'onboardingStep1', AppColors.pastelTeal),
    (Icons.show_chart_outlined, 'onboardingStep2', AppColors.pastelPink),
    (Icons.emoji_events_outlined, 'onboardingStep3', AppColors.coin),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bcn_onboarding_seen', true);

    if (_nameCtrl.text.trim().isNotEmpty) {
      await context.read<BabyProvider>().addBaby(
            name: _nameCtrl.text.trim(),
            birthDate: _birthDate,
          );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(key: MainShell.shellKey),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppDecorations.meshBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(onPressed: _finish, child: Text(AppStrings.t(context, 'skip'))),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _pages.length + 1,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    if (i == _pages.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppStrings.t(context, 'addBaby'), style: AppTypography.displayLarge(), textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _nameCtrl,
                              decoration: InputDecoration(labelText: AppStrings.t(context, 'babyName')),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(AppStrings.t(context, 'birthDate')),
                              subtitle: Text('${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _birthDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (d != null) setState(() => _birthDate = d);
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final (icon, descKey, color) = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (i == 0) ...[
                            Text(AppStrings.t(context, 'onboardingTitle'), textAlign: TextAlign.center, style: AppTypography.displayLarge()),
                            const SizedBox(height: 8),
                            Text(
                              AppStrings.t(context, 'onboardingSubtitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 32),
                          ],
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, size: 48, color: AppColors.primary),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            AppStrings.t(context, descKey),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant, height: 1.55),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length + 1,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (_page < _pages.length) {
                        _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(AppStrings.t(context, _page < _pages.length ? 'next' : 'getStarted')),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
