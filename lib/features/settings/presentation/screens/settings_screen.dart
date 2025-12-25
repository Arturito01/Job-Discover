import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/storage/settings_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../auth/providers/auth_provider.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const Gap.md(),

          // Appearance section
          _SectionHeader(title: 'Appearance'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _getThemeLabel(settings.themeMode),
            onTap: () => _showThemePicker(context, ref),
          ),

          const Gap.md(),

          // Preferences section
          _SectionHeader(title: 'Preferences'),
          _SettingsSwitch(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on interactions',
            value: settings.hapticFeedbackEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setHapticFeedbackEnabled(v),
          ),
          _SettingsSwitch(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Get notified about new jobs',
            value: settings.notificationsEnabled,
            onChanged: (v) => ref.read(settingsProvider.notifier).setNotificationsEnabled(v),
          ),

          const Gap.md(),

          // Language section
          _SectionHeader(title: 'Language'),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: _getLanguageLabel(settings.locale),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          const Gap.md(),

          // Account section
          _SectionHeader(title: 'Account'),
          if (isAuthenticated) ...[
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile coming soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              titleColor: AppColors.error,
              onTap: () => _showLogoutDialog(context, ref),
            ),
          ] else ...[
            _SettingsTile(
              icon: Icons.login_rounded,
              title: 'Sign In',
              onTap: () => context.push('/login'),
            ),
          ],

          const Gap.md(),

          // About section
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About Job Discover',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),

          const Gap.xl(),
        ],
      ),
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };
  }

  String _getLanguageLabel(String locale) {
    return switch (locale) {
      'en' => 'English',
      'es' => 'Español',
      'fr' => 'Français',
      'de' => 'Deutsch',
      _ => 'English',
    };
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(settingsProvider).themeMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap.md(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap.lg(),
            Text('Choose Theme', style: AppTypography.headlineSmall),
            const Gap.md(),
            ...ThemeMode.values.map((mode) {
              final isSelected = mode == currentTheme;
              return ListTile(
                leading: Icon(
                  mode == ThemeMode.system
                      ? Icons.brightness_auto
                      : mode == ThemeMode.light
                          ? Icons.light_mode
                          : Icons.dark_mode,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                title: Text(
                  _getThemeLabel(mode),
                  style: AppTypography.bodyLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setThemeMode(mode);
                  Navigator.pop(context);
                },
              );
            }),
            const Gap.md(),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(settingsProvider).locale;
    final languages = [
      ('en', 'English'),
      ('es', 'Español'),
      ('fr', 'Français'),
      ('de', 'Deutsch'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap.md(),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap.lg(),
            Text('Choose Language', style: AppTypography.headlineSmall),
            const Gap.md(),
            ...languages.map((lang) {
              final isSelected = lang.$1 == currentLocale;
              return ListTile(
                title: Text(
                  lang.$2,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(settingsProvider.notifier).setLocale(lang.$1);
                  Navigator.pop(context);
                },
              );
            }),
            const Gap.md(),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pop(context);
              context.go('/');
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.work_rounded, color: AppColors.primary),
            const Gap.sm(),
            const Text('Job Discover'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            Gap.sm(),
            Text(
              'A modern job discovery app built with Flutter, '
              'demonstrating clean architecture and best practices.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTypography.bodySmall)
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(subtitle, style: AppTypography.bodySmall),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
