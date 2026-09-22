import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/capsule.dart';

class CapsuleCard extends StatelessWidget {
  final Capsule capsule;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CapsuleCard({
    super.key,
    required this.capsule,
    this.onTap,
    this.onDelete,
  });

  String get _typeEmoji {
    switch (capsule.type) {
      case CapsuleType.time:
        return '⏰';
      case CapsuleType.location:
        return '📍';
      case CapsuleType.friend:
        return '👥';
      case CapsuleType.surprise:
        return '🎁';
      case CapsuleType.ai:
        return '🤖';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = capsule.isUnlocked;

    return GestureDetector(
      onTap: onTap ?? () => context.push('/capsule/${capsule.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: unlocked ? AppTheme.unlockedGradient : AppTheme.lockedGradient,
          boxShadow: [
            BoxShadow(
              color: (unlocked ? AppTheme.gold : AppTheme.purple)
                  .withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_typeEmoji, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              capsule.type.name.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Lock status
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),

                      if (onDelete != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title (hide if surprise and locked)
                  if (capsule.isSurprise && !unlocked)
                    const Text(
                      '🎁 Surprise Capsule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  else
                    Text(
                      capsule.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 6),

                  // Message preview
                  if (!capsule.isSurprise || unlocked)
                    Text(
                      capsule.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // Footer row
                  Row(
                    children: [
                      // Mood
                      if (capsule.mood != null) ...[
                        Text(capsule.mood!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                      ],

                      // Countdown or unlocked
                      Expanded(
                        child: capsule.openDate == null
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Location Lock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              )
                            : unlocked
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Unlocked',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        color: Colors.white.withValues(alpha: 0.7),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppDateUtils.getCountdown(capsule.openDate!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),

                      // Created date
                      Text(
                        AppDateUtils.formatDate(capsule.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }
}
