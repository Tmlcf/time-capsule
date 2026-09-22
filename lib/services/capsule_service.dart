import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/capsule.dart';

class CapsuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> createCapsule({
    required String title,
    required String message,
    required CapsuleType type,
    CapsuleVisibility visibility = CapsuleVisibility.private,
    DateTime? openDate,
    double? latitude,
    double? longitude,
    int radiusMeters = 100,
    bool isSurprise = false,
    String? mood,
    String? chainId,
    int? chainOrder,
  }) async {
    await _supabase.from('capsules').insert({
      'user_id': _userId,
      'title': title,
      'message': message,
      'type': type.name,
      'visibility': visibility.name,
      'open_date': openDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
      'is_opened': false,
      'is_surprise': isSurprise,
      'mood': mood,
      'chain_id': chainId,
      'chain_order': chainOrder,
    });
  }

  // ── Read ──────────────────────────────────────────────────────────────────
  Future<List<Capsule>> getCapsules() async {
    final response = await _supabase
        .from('capsules')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Capsule.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<Capsule?> getCapsule(String id) async {
    final response = await _supabase
        .from('capsules')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Capsule.fromMap(response);
  }

  Future<List<Capsule>> getPublicCapsules() async {
    final response = await _supabase
        .from('capsules')
        .select()
        .eq('visibility', 'public')
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((map) => Capsule.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> markAsOpened(String id) async {
    await _supabase
        .from('capsules')
        .update({'is_opened': true})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  Future<void> updateVisibility(String id, CapsuleVisibility visibility) async {
    await _supabase
        .from('capsules')
        .update({'visibility': visibility.name})
        .eq('id', id)
        .eq('user_id', _userId);
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> deleteCapsule(String id) async {
    await _supabase.from('capsules').delete().eq('id', id).eq('user_id', _userId);
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Future<Map<String, int>> getStats() async {
    final capsules = await getCapsules();
    final locked = capsules.where((c) => !c.isUnlocked).length;
    final unlocked = capsules.where((c) => c.isUnlocked).length;
    return {
      'total': capsules.length,
      'locked': locked,
      'unlocked': unlocked,
    };
  }

  /// Capsule closest to opening (min remaining time, not yet opened)
  Future<Capsule?> getNextToOpen() async {
    final capsules = await getCapsules();
    final locked = capsules.where((c) => !c.isUnlocked && c.openDate != null).toList();
    if (locked.isEmpty) return null;
    locked.sort((a, b) => a.openDate!.compareTo(b.openDate!));
    return locked.first;
  }
}
