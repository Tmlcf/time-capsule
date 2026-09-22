import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadMedia({
    required File file,
    required String capsuleId,
    required String mediaType,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final ext = file.path.split('.').last;
    final fileName = '$userId/$capsuleId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage
        .from('capsule-media')
        .upload(fileName, file, fileOptions: FileOptions(contentType: _getMimeType(ext)));

    return _supabase.storage.from('capsule-media').getPublicUrl(fileName);
  }

  Future<void> deleteMedia(String url) async {
    try {
      final uri = Uri.parse(url);
      // Extract path after bucket name
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('capsule-media');
      if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
        final path = segments.sublist(bucketIndex + 1).join('/');
        await _supabase.storage.from('capsule-media').remove([path]);
      }
    } catch (_) {}
  }

  String _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      case 'm4a':
        return 'audio/m4a';
      default:
        return 'application/octet-stream';
    }
  }
}
