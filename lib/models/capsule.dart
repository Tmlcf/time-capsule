class Capsule {
  final String id;
  final String? userId;
  final String title;
  final String message;
  final DateTime openDate;
  final DateTime createdAt;
  final bool isOpened;
  final String? recipientEmail; // email ของผู้รับ (ถ้าส่งให้เพื่อน)
  final String? mood; // อารมณ์ความรู้สึก เช่น '😊 Happy'
  final String? imageUrl; // URL ของรูปภาพใน Supabase Storage

  Capsule({
    required this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.openDate,
    required this.createdAt,
    required this.isOpened,
    this.recipientEmail,
    this.mood,
    this.imageUrl,
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
      recipientEmail: map['recipient_email'] as String?,
      mood: map['mood'] as String?,
      imageUrl: map['image_url'] as String?,
    );
  }

  bool get hasRecipient =>
      recipientEmail != null && recipientEmail!.isNotEmpty;

  bool get hasMood => mood != null && mood!.isNotEmpty;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
}
