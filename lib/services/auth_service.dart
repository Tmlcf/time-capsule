import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthService — รวม logic ทั้งหมดสำหรับ Supabase Authentication
///
/// วิธีใช้ใน Widget:
///   final authService = ref.read(authServiceProvider);
///   await authService.signIn(email: '...', password: '...');
class AuthService {
  final _supabase = Supabase.instance.client;

  /// ดึง user ที่ login อยู่ปัจจุบัน (null ถ้ายังไม่ได้ login)
  User? get currentUser => _supabase.auth.currentUser;

  /// ดึง user.id ของคนที่ login อยู่ (ใช้กับ capsules.user_id)
  String? get userId => _supabase.auth.currentUser?.id;

  /// Stream สำหรับ listen การเปลี่ยนแปลง auth state (login/logout)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// สมัครสมาชิกด้วย email + password
  ///
  /// ถ้า Supabase ตั้งค่า email confirmation ไว้:
  ///   - response.session จะเป็น null
  ///   - response.user จะมีข้อมูล แต่ยังใช้งานไม่ได้จนกว่าจะยืนยัน email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  /// เข้าสู่ระบบด้วย email + password
  ///
  /// Throws exception ถ้า credentials ไม่ถูกต้อง
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// ออกจากระบบ
  Future<void> signOut() {
    return _supabase.auth.signOut();
  }
}
