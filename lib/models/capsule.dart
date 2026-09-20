class Capsule {
  final String id;
  final String? userId;
  final String title;
  final String message;
  final DateTime openDate;
  final DateTime createdAt;
  final bool isOpened;

  Capsule({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.openDate,
    required this.createdAt,
    required this.isOpened,
  });

  factory Capsule.fromMap(Map<String, dynamic> map) {
    return Capsule(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      message: map['message'],
      openDate: DateTime.parse(map['open_date']),
      createdAt: DateTime.parse(map['created_at']),
      isOpened: map['is_opened'] ?? false,
    );
  }
}
