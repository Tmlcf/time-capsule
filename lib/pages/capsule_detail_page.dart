import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  void _checkUnlockStatus() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final openDate = DateTime(widget.capsule.openDate.year, widget.capsule.openDate.month, widget.capsule.openDate.day);
    
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capsule Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            Text(
              widget.capsule.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _isUnlocked
                  ? 'เปิดเมื่อ ${widget.capsule.openDate.day.toString().padLeft(2, '0')}/${widget.capsule.openDate.month.toString().padLeft(2, '0')}/${widget.capsule.openDate.year}'
                  : 'Capsule นี้จะเปิดได้ในวันที่\n${widget.capsule.openDate.day.toString().padLeft(2, '0')}/${widget.capsule.openDate.month.toString().padLeft(2, '0')}/${widget.capsule.openDate.year}',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            if (_isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  widget.capsule.message,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                ),
              )
            else
              Text(
                'อดใจรออีกนิดนะ ⏳',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
