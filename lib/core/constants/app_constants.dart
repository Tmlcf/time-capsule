class AppConstants {
  // Supabase tables
  static const String capsulesTable = 'capsules';
  static const String capsuleMediaTable = 'capsule_media';
  static const String capsuleMembersTable = 'capsule_members';
  static const String notificationsTable = 'notifications';
  static const String usersTable = 'users';

  // Supabase storage
  static const String capsuleMediaBucket = 'capsule-media';

  // Default geofence
  static const int defaultRadiusMeters = 100;

  // Moods
  static const List<Map<String, String>> moods = [
    {'emoji': '😀', 'label': 'Happy'},
    {'emoji': '😂', 'label': 'Fun'},
    {'emoji': '🥹', 'label': 'Nostalgic'},
    {'emoji': '❤️', 'label': 'Love'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  // Geofence radii
  static const List<int> radiusOptions = [100, 500, 1000];
  static const List<String> radiusLabels = ['100 ม.', '500 ม.', '1 กม.'];

  // Capsule type labels
  static const Map<String, String> capsuleTypeLabels = {
    'time': 'Time Capsule',
    'location': 'Location Capsule',
    'friend': 'Friend Capsule',
    'surprise': 'Surprise Capsule',
    'ai': 'AI Memory',
  };

  // Capsule type emojis
  static const Map<String, String> capsuleTypeEmojis = {
    'time': '⏰',
    'location': '📍',
    'friend': '👥',
    'surprise': '🎁',
    'ai': '🤖',
  };
}
