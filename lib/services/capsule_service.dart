import 'package:supabase_flutter/supabase_flutter.dart';

class CapsuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createCapsule({
    required String title,
    required String message,
    required DateTime openDate,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('ยังไม่ได้เข้าสู่ระบบ');

    await _supabase.from('capsules').insert({
      'user_id': user.id,
      'title': title,
      'message': message,
      'open_date': openDate.toIso8601String().split('T').first,
    });
  }

  Future<List<Map<String, dynamic>>> getCapsules() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('ยังไม่ได้เข้าสู่ระบบ');

    final response = await _supabase
        .from('capsules')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markAsOpened(String capsuleId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('ยังไม่ได้เข้าสู่ระบบ');

    await _supabase
        .from('capsules')
        .update({'is_opened': true})
        .eq('id', capsuleId)
        .eq('user_id', user.id);
  }
}
