enum CapsuleType { time, location, friend, surprise, ai }

enum CapsuleVisibility { private, friends, public }

class Capsule {
  final String id;
  final String userId;
  final String title;
  final String message;
  final CapsuleType type;
  final CapsuleVisibility visibility;
  final DateTime? openDate;
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final bool isOpened;
  final bool isSurprise;
  final String? mood;
  final String? chainId;
  final int? chainOrder;
  final DateTime createdAt;

  const Capsule({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.visibility,
    this.openDate,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100,
    required this.isOpened,
    this.isSurprise = false,
    this.mood,
    this.chainId,
    this.chainOrder,
    required this.createdAt,
  });

  /// True if the capsule has been unlocked (time passed or already opened)
  bool get isUnlocked {
    if (isOpened) return true;
    if (openDate != null && DateTime.now().isAfter(openDate!)) return true;
    return false;
  }

  bool get hasLocation => latitude != null && longitude != null;

  factory Capsule.fromMap(Map<String, dynamic> map) {
    return Capsule(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      message: map['message'] as String? ?? '',
      type: CapsuleType.values.firstWhere(
        (e) => e.name == (map['type'] as String? ?? 'time'),
        orElse: () => CapsuleType.time,
      ),
      visibility: CapsuleVisibility.values.firstWhere(
        (e) => e.name == (map['visibility'] as String? ?? 'private'),
        orElse: () => CapsuleVisibility.private,
      ),
      openDate:
          map['open_date'] != null ? DateTime.parse(map['open_date'] as String) : null,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      radiusMeters: map['radius_meters'] as int? ?? 100,
      isOpened: map['is_opened'] as bool? ?? false,
      isSurprise: map['is_surprise'] as bool? ?? false,
      mood: map['mood'] as String?,
      chainId: map['chain_id'] as String?,
      chainOrder: map['chain_order'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() => {
    'user_id': userId,
    'title': title,
    'message': message,
    'type': type.name,
    'visibility': visibility.name,
    'open_date': openDate?.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'radius_meters': radiusMeters,
    'is_opened': isOpened,
    'is_surprise': isSurprise,
    'mood': mood,
    'chain_id': chainId,
    'chain_order': chainOrder,
  };

  Capsule copyWith({
    bool? isOpened,
    String? mood,
    DateTime? openDate,
    CapsuleVisibility? visibility,
  }) {
    return Capsule(
      id: id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      visibility: visibility ?? this.visibility,
      openDate: openDate ?? this.openDate,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      isOpened: isOpened ?? this.isOpened,
      isSurprise: isSurprise,
      mood: mood ?? this.mood,
      chainId: chainId,
      chainOrder: chainOrder,
      createdAt: createdAt,
    );
  }
}
