import 'package:flutter/material.dart';
import 'package:time_capsule/core/theme/app_theme.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';
import 'package:time_capsule/widgets/countdown_widget.dart';

class CapsuleDetailPage extends StatefulWidget {
  final String capsuleId;

  const CapsuleDetailPage({super.key, required this.capsuleId});

  @override
  State<CapsuleDetailPage> createState() => _CapsuleDetailPageState();
}

class _CapsuleDetailPageState extends State<CapsuleDetailPage> {
  final CapsuleService _capsuleService = CapsuleService();
  late Future<Capsule?> _capsuleFuture;

  @override
  void initState() {
    super.initState();
    _loadCapsule();
  }

  void _loadCapsule() {
    _capsuleFuture = _capsuleService.getCapsule(widget.capsuleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capsule Detail'),
      ),
      body: FutureBuilder<Capsule?>(
        future: _capsuleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error loading capsule: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _loadCapsule());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final capsule = snapshot.data;
          if (capsule == null) {
            return const Center(
              child: Text(
                'Capsule not found',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final unlocked = capsule.isUnlocked;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: unlocked
                        ? AppTheme.unlockedGradient
                        : AppTheme.lockedGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                        size: 56,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        capsule.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        unlocked ? 'Unlocked 🎉' : 'Locked 🔒',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (!unlocked && capsule.openDate != null) ...[
                  const Text(
                    'Time Remaining',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CountdownWidget(openDate: capsule.openDate!),
                  const SizedBox(height: 24),
                ],

                const Text(
                  'Message',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    unlocked
                        ? capsule.message
                        : '🔒 This message is locked until the opening condition is met.',
                    style: TextStyle(
                      fontSize: 16,
                      color: unlocked ? null : Colors.grey.shade600,
                      fontStyle: unlocked ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
