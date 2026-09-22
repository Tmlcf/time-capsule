import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:time_capsule/models/capsule.dart';

class CapsuleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  User _getRequiredUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError(
        'กรุณาเข้าสู่ระบบก่อนทำรายการ (User is not authenticated)',
      );
    }
    return user;
  }

  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = _getRequiredUser();
    final userId = user.id;

    final cleanFileName =
        fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    final storagePath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_$cleanFileName';

    final ext = fileName.split('.').last.toLowerCase();

    String mimeType = 'image/jpeg';

    if (ext == 'png') {
      mimeType = 'image/png';
    } else if (ext == 'webp') {
      mimeType = 'image/webp';
    } else if (ext == 'gif') {
      mimeType = 'image/gif';
    }

    await _supabase.storage.from('capsule-images').uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(
        contentType: mimeType,
        upsert: true,
      ),
    );

    return _supabase.storage
        .from('capsule-images')
        .getPublicUrl(storagePath);
  }

  Future<String> getSignedUrl(
    String storagePath, {
    int expiresIn = 3600,
  }) async {
    return await _supabase.storage
        .from('capsule-images')
        .createSignedUrl(storagePath, expiresIn);
  }

  Future<void> createCapsule({
    required String title,
    required String message,
    required DateTime openDate,
    String? recipientEmail,
    String? mood,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    final user = _getRequiredUser();
    final userId = user.id;

    String? imageUrl;

    if (imageBytes != null && imageFileName != null) {
      imageUrl = await uploadImage(
        bytes: imageBytes,
        fileName: imageFileName,
      );
    }

    await _supabase.from('capsules').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'open_date': openDate.toIso8601String().split('T').first,
      if (recipientEmail != null && recipientEmail.trim().isNotEmpty)
        'recipient_email': recipientEmail.trim().toLowerCase(),
      if (mood != null && mood.trim().isNotEmpty) 'mood': mood.trim(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'image_url': imageUrl.trim(),
    });
  }

  Future<List<Capsule>> getCapsules() async {
    final user = _getRequiredUser();

    final response = await _supabase
        .from('capsules')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Capsule.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<List<Capsule>> getReceivedCapsules() async {
    final user = _getRequiredUser();
    final userEmail = user.email;

    if (userEmail == null || userEmail.isEmpty) {
      return [];
    }

    final response = await _supabase
        .from('capsules')
        .select()
        .eq('recipient_email', userEmail.toLowerCase())
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Capsule.fromMap(map as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsOpened(String capsuleId) async {
    final user = _getRequiredUser();

    await _supabase
        .from('capsules')
        .update({'is_opened': true})
        .eq('id', capsuleId)
        .eq('user_id', user.id);
  }

  Future<void> deleteCapsule(String capsuleId) async {
    final user = _getRequiredUser();

    debugPrint('🗑️ Deleting capsule: $capsuleId');
    debugPrint('👤 Current user: ${user.id}');

    await _supabase
        .from('capsules')
        .delete()
        .eq('id', capsuleId)
        .eq('user_id', user.id);

    debugPrint('✅ Delete request sent successfully');
  }
}