import 'package:intl/intl.dart';

class AppDateUtils {
  /// Format: 20 ก.ย. 2026
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format: 20 ก.ย. 2026, 16:30
  static String formatDateTime(DateTime date) {
    return DateFormat('d MMM yyyy, HH:mm').format(date);
  }

  /// Human-readable countdown (e.g. "อีก 182 วัน", "อีก 3 ชั่วโมง")
  static String getCountdown(DateTime openDate) {
    final now = DateTime.now();
    final diff = openDate.difference(now);

    if (diff.isNegative) return 'เปิดได้แล้ว';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 365) {
      final years = (days / 365).floor();
      return 'อีก $years ปี';
    }
    if (days > 0) return 'อีก $days วัน';
    if (hours > 0) return 'อีก $hours ชั่วโมง';
    if (minutes > 0) return 'อีก $minutes นาที';
    return 'อีก $seconds วินาที';
  }

  /// Full countdown breakdown for display widget
  static Map<String, int> getCountdownParts(DateTime openDate) {
    final now = DateTime.now();
    final diff = openDate.difference(now);
    if (diff.isNegative) return {'days': 0, 'hours': 0, 'minutes': 0, 'seconds': 0};
    return {
      'days': diff.inDays,
      'hours': diff.inHours % 24,
      'minutes': diff.inMinutes % 60,
      'seconds': diff.inSeconds % 60,
    };
  }

  /// True if openDate is now or past
  static bool isUnlocked(DateTime openDate) {
    return DateTime.now().isAfter(openDate) || DateTime.now().isAtSameMomentAs(openDate);
  }

  /// Days since creation
  static int daysSinceCreation(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays;
  }
}
