import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';

class CapsulesPage extends StatefulWidget {
  const CapsulesPage({super.key});

  @override
  State<CapsulesPage> createState() => _CapsulesPageState();
}

class _CapsulesPageState extends State<CapsulesPage> {
  final CapsuleService _capsuleService = CapsuleService();
  late Future<List<Capsule>> _capsulesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCapsules();
  }

  void _fetchCapsules() {
    _capsulesFuture = _capsuleService.getCapsules().then(
      (data) => data.map((e) => Capsule.fromMap(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Capsules'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _fetchCapsules();
              });
            },
          )
        ],
      ),
      body: FutureBuilder<List<Capsule>>(
        future: _capsulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final capsules = snapshot.data ?? [];
          if (capsules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'ยังไม่มี Time Capsule',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ลองสร้างข้อความถึงอนาคตของคุณดู ⏳',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _fetchCapsules();
              });
              await _capsulesFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: capsules.length,
              itemBuilder: (context, index) {
                final capsule = capsules[index];
                final openDate = DateTime(capsule.openDate.year, capsule.openDate.month, capsule.openDate.day);
                final isUnlocked = today.isAtSameMomentAs(openDate) || today.isAfter(openDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked ? Colors.green.shade100 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isUnlocked ? Icons.lock_open : Icons.lock,
                        color: isUnlocked ? Colors.green : Colors.grey.shade700,
                      ),
                    ),
                    title: Text(
                      '${isUnlocked ? '🔓' : '🔒'} ${capsule.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('สร้างเมื่อ: ${capsule.createdAt.day.toString().padLeft(2, '0')}/${capsule.createdAt.month.toString().padLeft(2, '0')}/${capsule.createdAt.year}'),
                          Text('เปิดวันที่: ${capsule.openDate.day.toString().padLeft(2, '0')}/${capsule.openDate.month.toString().padLeft(2, '0')}/${capsule.openDate.year}'),
                          const SizedBox(height: 4),
                          Text(
                            isUnlocked ? 'Unlocked' : 'Locked',
                            style: TextStyle(
                              color: isUnlocked ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await context.push('/capsules/detail', extra: capsule);
                      setState(() {
                        _fetchCapsules(); 
                      });
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
