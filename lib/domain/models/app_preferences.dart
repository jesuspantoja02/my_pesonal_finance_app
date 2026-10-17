import 'package:flutter/material.dart';

enum AppThemePreference { dark, light, system }

class AppPreferences {
  const AppPreferences({
    required this.currencyCode,
    required this.themePreference,
    required this.onboardingCompleted,
    required this.appLockEnabled,
  });

  final String currencyCode;
  final AppThemePreference themePreference;
  final bool onboardingCompleted;
  final bool appLockEnabled;

  ThemeMode get themeMode {
    return switch (themePreference) {
      AppThemePreference.dark => ThemeMode.dark,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.system => ThemeMode.system,
    };
  }
}
