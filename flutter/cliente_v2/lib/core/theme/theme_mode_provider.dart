import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../constants/app_constants.dart';

final appThemeModeProvider =
    StateNotifierProvider<AppThemeModeController, ThemeMode>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return AppThemeModeController(prefs);
    });

class AppThemeModeController extends StateNotifier<ThemeMode> {
  AppThemeModeController(this._prefs) : super(_readThemeMode(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readThemeMode(SharedPreferences prefs) {
    final value = prefs.getString(AppConstants.themeKey);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get label {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.themeKey, value);
  }
}
