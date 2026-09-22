class AppUser {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    required this.createdAt,
  });

  String get displayName => username ?? email.split('@').first;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'email': email,
    'username': username,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };
}
