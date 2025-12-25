import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_service.dart';

/// Settings keys
abstract final class SettingsKeys {
  static const themeMode = 'themeMode';
  static const locale = 'locale';
  static const hasSeenOnboarding = 'hasSeenOnboarding';
  static const notificationsEnabled = 'notificationsEnabled';
  static const hapticFeedbackEnabled = 'hapticFeedbackEnabled';
}

/// App settings state
class AppSettings {
  final ThemeMode themeMode;
  final String locale;
  final bool hasSeenOnboarding;
  final bool notificationsEnabled;
  final bool hapticFeedbackEnabled;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = 'en',
    this.hasSeenOnboarding = false,
    this.notificationsEnabled = true,
    this.hapticFeedbackEnabled = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? locale,
    bool? hasSeenOnboarding,
    bool? notificationsEnabled,
    bool? hapticFeedbackEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
    );
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

/// Theme mode provider (convenience accessor)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    final themeModeIndex = _storage.getSetting<int>(
      SettingsKeys.themeMode,
      defaultValue: ThemeMode.system.index,
    );
    final locale = _storage.getSetting<String>(
      SettingsKeys.locale,
      defaultValue: 'en',
    );
    final hasSeenOnboarding = _storage.getSetting<bool>(
      SettingsKeys.hasSeenOnboarding,
      defaultValue: false,
    );
    final notificationsEnabled = _storage.getSetting<bool>(
      SettingsKeys.notificationsEnabled,
      defaultValue: true,
    );
    final hapticFeedbackEnabled = _storage.getSetting<bool>(
      SettingsKeys.hapticFeedbackEnabled,
      defaultValue: true,
    );

    state = AppSettings(
      themeMode: ThemeMode.values[themeModeIndex ?? 0],
      locale: locale ?? 'en',
      hasSeenOnboarding: hasSeenOnboarding ?? false,
      notificationsEnabled: notificationsEnabled ?? true,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _storage.setSetting(SettingsKeys.themeMode, mode.index);
  }

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _storage.setSetting(SettingsKeys.locale, locale);
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    state = state.copyWith(hasSeenOnboarding: value);
    await _storage.setSetting(SettingsKeys.hasSeenOnboarding, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    await _storage.setSetting(SettingsKeys.notificationsEnabled, value);
  }

  Future<void> setHapticFeedbackEnabled(bool value) async {
    state = state.copyWith(hapticFeedbackEnabled: value);
    await _storage.setSetting(SettingsKeys.hapticFeedbackEnabled, value);
  }
}
