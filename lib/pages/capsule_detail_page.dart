import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';

class CapsuleDetailPage extends StatefulWidget {
  final Capsule capsule;

  const CapsuleDetailPage({super.key, required this.capsule});

  @override
  State<CapsuleDetailPage> createState() => _CapsuleDetailPageState();
}

class _CapsuleDetailPageState extends State<CapsuleDetailPage> {
  final CapsuleService _capsuleService = CapsuleService();

  bool _isUnlocked = false;
  bool _isDeleting = false;

  static const Color _background = Color(0xFF0B0B1E);
  static const Color _surface = Color(0xFF15152B);
  static const Color _surfaceLight = Color(0xFF1D1D38);
  static const Color _purple = Color(0xFF651FFF);
  static const Color _purpleLight = Color(0xFF9D7CFF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA8A7C0);

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  void _checkUnlockStatus() {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final openDate = DateTime(
      widget.capsule.openDate.year,
      widget.capsule.openDate.month,
      widget.capsule.openDate.day,
    );

    setState(() {
      _isUnlocked = today.isAtSameMomentAs(openDate) || today.isAfter(openDate);
    });

    if (_isUnlocked && !widget.capsule.isOpened) {
      _markAsOpened();
    }
  }

  Future<void> _markAsOpened() async {
    try {
      await _capsuleService.markAsOpened(widget.capsule.id);
    } catch (e) {
      debugPrint('Failed to mark as opened: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        title: const Text(
          'ลบ Time Capsule?',
          style: TextStyle(color: _textPrimary),
        ),
        content: const Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบ Capsule นี้?\n'
          'การลบไม่สามารถย้อนกลับได้',
          style: TextStyle(color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _deleteCapsule();
  }

  Future<void> _deleteCapsule() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      await _capsuleService.deleteCapsule(widget.capsule.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบ Capsule สำเร็จ ✅')));

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text(
          'Capsule Detail',
          style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary),
        ),
        actions: [
          if (_isDeleting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _purpleLight,
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'ลบ Capsule',
              onPressed: _confirmDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.redAccent,
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusHero(
              isUnlocked: _isUnlocked,
              openDate: _formatDate(widget.capsule.openDate),
            ),

            const SizedBox(height: 20),

            _TitleSection(
              title: widget.capsule.title,
              hasMood: widget.capsule.hasMood,
              mood: widget.capsule.mood,
              hasRecipient: widget.capsule.hasRecipient,
              recipientEmail: widget.capsule.recipientEmail,
            ),

            const SizedBox(height: 20),

            if (_isUnlocked)
              _UnlockedContent(capsule: widget.capsule)
            else
              const _LockedContent(),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('ลบ Capsule นี้'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.55),
                  ),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Status Hero
// ================================================================

class _StatusHero extends StatelessWidget {
  final bool isUnlocked;
  final String openDate;

  const _StatusHero({required this.isUnlocked, required this.openDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _CapsuleDetailPageState._purple.withValues(alpha: 0.35),
            _CapsuleDetailPageState._surface,
            _CapsuleDetailPageState._surface,
          ],
        ),
        border: Border.all(
          color: _CapsuleDetailPageState._purple.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: _CapsuleDetailPageState._purple.withValues(alpha: 0.12),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? Colors.greenAccent.withValues(alpha: 0.12)
                  : _CapsuleDetailPageState._purple.withValues(alpha: 0.14),
              border: Border.all(
                color: isUnlocked
                    ? Colors.greenAccent.withValues(alpha: 0.35)
                    : _CapsuleDetailPageState._purpleLight.withValues(
                        alpha: 0.35,
                      ),
              ),
            ),
            child: Icon(
              isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
              size: 42,
              color: isUnlocked
                  ? Colors.greenAccent
                  : _CapsuleDetailPageState._purpleLight,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isUnlocked ? 'Capsule Unlocked' : 'Capsule Locked',
            style: const TextStyle(
              color: _CapsuleDetailPageState._textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isUnlocked
                ? 'ความทรงจำนี้เปิดให้คุณแล้ว'
                : 'ความทรงจำนี้ยังถูกเก็บไว้อย่างปลอดภัย',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _CapsuleDetailPageState._textSecondary,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: _CapsuleDetailPageState._purpleLight,
                ),
                const SizedBox(width: 7),
                Text(
                  isUnlocked
                      ? 'เปิดเมื่อ $openDate'
                      : 'เปิดได้วันที่ $openDate',
                  style: const TextStyle(
                    color: _CapsuleDetailPageState._textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Title Section
// ================================================================

class _TitleSection extends StatelessWidget {
  final String title;
  final bool hasMood;
  final String? mood;
  final bool hasRecipient;
  final String? recipientEmail;

  const _TitleSection({
    required this.title,
    required this.hasMood,
    required this.mood,
    required this.hasRecipient,
    required this.recipientEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _CapsuleDetailPageState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _CapsuleDetailPageState._purple.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _CapsuleDetailPageState._purple.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _CapsuleDetailPageState._purpleLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _CapsuleDetailPageState._textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          if (hasMood || hasRecipient) ...[
            const SizedBox(height: 18),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hasMood)
                  _InfoChip(
                    icon: Icons.mood_outlined,
                    label: mood!,
                    color: Colors.amberAccent,
                  ),
                if (hasRecipient)
                  _InfoChip(
                    icon: Icons.send_outlined,
                    label: 'ส่งถึง: $recipientEmail',
                    color: _CapsuleDetailPageState._purpleLight,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// Info Chip
// ================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Unlocked Content
// ================================================================

class _UnlockedContent extends StatelessWidget {
  final Capsule capsule;

  const _UnlockedContent({required this.capsule});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MessageCard(message: capsule.message),

        if (capsule.hasImage) ...[
          const SizedBox(height: 16),
          _ImageCard(imageUrl: capsule.imageUrl!),
        ],
      ],
    );
  }
}

// ================================================================
// Message Card
// ================================================================

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _CapsuleDetailPageState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _CapsuleDetailPageState._purple.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _CapsuleDetailPageState._purple.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: _CapsuleDetailPageState._purpleLight,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ข้อความจากอดีต',
                style: TextStyle(
                  color: _CapsuleDetailPageState._textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _CapsuleDetailPageState._surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border(
                left: BorderSide(
                  color: _CapsuleDetailPageState._purple,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: _CapsuleDetailPageState._textPrimary,
                fontSize: 16,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Image Card
// ================================================================

class _ImageCard extends StatelessWidget {
  final String imageUrl;

  const _ImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _CapsuleDetailPageState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _CapsuleDetailPageState._purple.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 4, 6, 12),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  color: _CapsuleDetailPageState._purpleLight,
                  size: 21,
                ),
                SizedBox(width: 10),
                Text(
                  'รูปภาพแนบ',
                  style: TextStyle(
                    color: _CapsuleDetailPageState._textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Container(
                  height: 220,
                  color: _CapsuleDetailPageState._surfaceLight,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: _CapsuleDetailPageState._purpleLight,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: double.infinity,
                  color: _CapsuleDetailPageState._surfaceLight,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 42,
                        color: _CapsuleDetailPageState._textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ไม่สามารถโหลดรูปภาพได้',
                        style: TextStyle(
                          color: _CapsuleDetailPageState._textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// Locked Content
// ================================================================

class _LockedContent extends StatelessWidget {
  const _LockedContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: _CapsuleDetailPageState._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _CapsuleDetailPageState._purple.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _CapsuleDetailPageState._purple.withValues(alpha: 0.10),
              border: Border.all(
                color: _CapsuleDetailPageState._purple.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              size: 40,
              color: _CapsuleDetailPageState._purpleLight,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            '⏳ ยังไม่ถึงเวลา',
            style: TextStyle(
              color: _CapsuleDetailPageState._textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'อดใจรออีกนิดนะ\nความทรงจำนี้ยังถูกล็อกอยู่',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _CapsuleDetailPageState._textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
