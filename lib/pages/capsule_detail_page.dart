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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบ Time Capsule?'),
        content: const Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบ Capsule นี้?\nการลบไม่สามารถย้อนกลับได้',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _deleteCapsule();
  }

  Future<void> _deleteCapsule() async {
    setState(() => _isDeleting = true);
    try {
      await _capsuleService.deleteCapsule(widget.capsule.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบ Capsule สำเร็จ ✅')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capsule Detail'),
        actions: [
          // ─── Delete Button ───
          _isDeleting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'ลบ Capsule',
                  onPressed: _confirmDelete,
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ─── Lock Icon ───
            Icon(
              _isUnlocked ? Icons.lock_open : Icons.lock,
              size: 80,
              color: _isUnlocked ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _isUnlocked ? '🔓 Capsule Unlocked' : '🔒 Capsule Locked',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _isUnlocked ? Colors.green : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // ─── Title ───
            Text(
              widget.capsule.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // ─── Date ───
            Text(
              _isUnlocked
                  ? 'เปิดเมื่อ ${_formatDate(widget.capsule.openDate)}'
                  : 'เปิดได้วันที่\n${_formatDate(widget.capsule.openDate)}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // ─── Mood & Recipient ───
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (widget.capsule.hasMood)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      widget.capsule.mood!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (widget.capsule.hasRecipient)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_outlined, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'ส่งถึง: ${widget.capsule.recipientEmail}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // ─── Message or Locked message ───
            if (_isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อความ:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.capsule.message,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                    ),
                    if (widget.capsule.hasImage) ...[
                      const SizedBox(height: 24),
                      Text(
                        'รูปภาพแนบ:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.capsule.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 120,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_outlined, color: Colors.grey),
                                  SizedBox(height: 4),
                                  Text('ไม่สามารถโหลดรูปภาพได้',
                                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    '⏳ ยังไม่ถึงเวลา',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'อดใจรออีกนิดนะ',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                ],
              ),

            const SizedBox(height: 40),

            // ─── Delete Button (bottom) ───
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDeleting ? null : _confirmDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'ลบ Capsule นี้',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
