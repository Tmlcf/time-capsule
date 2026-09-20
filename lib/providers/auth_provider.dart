import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:time_capsule/services/auth_service.dart';

/// Provider สำหรับ AuthService
/// ใช้ใน Widget:  ref.read(authServiceProvider)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// StreamProvider ที่ listen การเปลี่ยนแปลง auth state
/// ใช้ใน Widget:  ref.watch(authStateProvider)
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ============================================================
// ThemeMode Notifier สำหรับ riverpod v3
// ============================================================
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setDark() => state = ThemeMode.dark;
  void setLight() => state = ThemeMode.light;
  void setSystem() => state = ThemeMode.system;
  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

/// Provider สำหรับควบคุม Dark/Light mode ทั้งแอป
/// ใช้ใน Widget:
///   ref.read(themeModeProvider.notifier).setDark()
///   ref.read(themeModeProvider.notifier).setLight()
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
