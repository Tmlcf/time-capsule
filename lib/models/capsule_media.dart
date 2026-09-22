enum MediaType { image, video, audio }

class CapsuleMedia {
  final String id;
  final String capsuleId;
  final MediaType type;
  final String url;
  final DateTime createdAt;

  const CapsuleMedia({
    required this.id,
    required this.capsuleId,
    required this.type,
    required this.url,
    required this.createdAt,
  });

  factory CapsuleMedia.fromMap(Map<String, dynamic> map) {
    return CapsuleMedia(
      id: map['id'] as String,
      capsuleId: map['capsule_id'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'image'),
        orElse: () => MediaType.image,
      ),
      url: map['url'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'capsule_id': capsuleId,
    'type': type.name,
    'url': url,
  };
}
