import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsState {
  final bool requireBiometrics;
  final bool pushNotifications;
  final bool emailReceipts;
  final bool smsAlerts;
  final bool isDarkMode;

  const SettingsState({
    this.requireBiometrics = false,
    this.pushNotifications = true,
    this.emailReceipts = true,
    this.smsAlerts = false,
    this.isDarkMode = true, // Default to true since the app is dark theme
  });

  SettingsState copyWith({
    bool? requireBiometrics,
    bool? pushNotifications,
    bool? emailReceipts,
    bool? smsAlerts,
    bool? isDarkMode,
  }) {
    return SettingsState(
      requireBiometrics: requireBiometrics ?? this.requireBiometrics,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailReceipts: emailReceipts ?? this.emailReceipts,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  final _supabase = Supabase.instance.client;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      requireBiometrics: prefs.getBool('requireBiometrics') ?? false,
      pushNotifications: prefs.getBool('pushNotifications') ?? true,
      emailReceipts: prefs.getBool('emailReceipts') ?? true,
      smsAlerts: prefs.getBool('smsAlerts') ?? false,
      isDarkMode: prefs.getBool('isDarkMode') ?? true,
    );
    
    // Optionally fetch from DB to keep in sync if authenticated
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase.from('users').select('push_notifications, email_receipts, sms_alerts, require_biometrics').eq('id', user.id).maybeSingle();
        if (data != null) {
          state = state.copyWith(
            pushNotifications: data['push_notifications'] as bool? ?? state.pushNotifications,
            emailReceipts: data['email_receipts'] as bool? ?? state.emailReceipts,
            smsAlerts: data['sms_alerts'] as bool? ?? state.smsAlerts,
            requireBiometrics: data['require_biometrics'] as bool? ?? state.requireBiometrics,
          );
          // Update local prefs with db state
          await prefs.setBool('pushNotifications', state.pushNotifications);
          await prefs.setBool('emailReceipts', state.emailReceipts);
          await prefs.setBool('smsAlerts', state.smsAlerts);
          await prefs.setBool('requireBiometrics', state.requireBiometrics);
        }
      }
    } catch (e) {
      print('Failed to sync settings from DB: $e');
    }
  }

  Future<void> _updateDbSetting(String column, bool value) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('users').update({column: value}).eq('id', user.id);
      }
    } catch (e) {
      print('Failed to update $column to DB: $e');
    }
  }

  Future<void> setRequireBiometrics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('requireBiometrics', value);
    state = state.copyWith(requireBiometrics: value);
    await _updateDbSetting('require_biometrics', value);
  }

  Future<void> setPushNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotifications', value);
    state = state.copyWith(pushNotifications: value);
    await _updateDbSetting('push_notifications', value);
  }

  Future<void> setEmailReceipts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailReceipts', value);
    state = state.copyWith(emailReceipts: value);
    await _updateDbSetting('email_receipts', value);
  }

  Future<void> setSmsAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smsAlerts', value);
    state = state.copyWith(smsAlerts: value);
    await _updateDbSetting('sms_alerts', value);
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    state = state.copyWith(isDarkMode: value);
    // Dark mode is local only, no DB sync needed usually
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
