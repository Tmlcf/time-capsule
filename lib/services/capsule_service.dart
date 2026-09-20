import 'package:supabase_flutter/supabase_flutter.dart';

class CapsuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createCapsule({
    required String title,
    required String message,
    required DateTime openDate,
  }) async {
    await _supabase.from('capsules').insert({
      'title': title,
      'message': message,
      'open_date': openDate.toIso8601String().split('T').first,
    });
  }

  Future<List<Map<String, dynamic>>> getCapsules() async {
    final response = await _supabase
        .from('capsules')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
