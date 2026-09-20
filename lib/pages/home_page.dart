import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/services/capsule_service.dart';
import 'package:time_capsule/models/capsule.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: const Text(
          'Time Capsule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _fetchCapsules();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
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
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          int total = capsules.length;
          int unlocked = capsules.where((c) {
            final openDate = DateTime(c.openDate.year, c.openDate.month, c.openDate.day);
            return today.isAtSameMomentAs(openDate) || today.isAfter(openDate);
          }).length;
          int locked = total - unlocked;

          Capsule? latestCapsule = capsules.isNotEmpty ? capsules.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สวัสดี 👋',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'เก็บความทรงจำของคุณไว้ใน Time Capsule',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('ทั้งหมด', total.toString(), Colors.blue),
                    _buildStatCard('Locked', locked.toString(), Colors.grey),
                    _buildStatCard('Unlocked', unlocked.toString(), Colors.green),
                  ],
                ),
                const SizedBox(height: 24),

                // Create Capsule
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.add_circle_outline, size: 40),
                      const SizedBox(height: 12),
                      const Text(
                        'สร้าง Time Capsule',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เขียนข้อความ เก็บรูปภาพ และส่งความทรงจำไปยังอนาคต',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await context.push('/create');
                          setState(() {
                            _fetchCapsules();
                          });
                        },
                        child: const Text('สร้าง Capsule'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Latest Capsule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (latestCapsule == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มี Capsule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'สร้าง Capsule แรกของคุณเพื่อเริ่มเก็บความทรงจำ',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Icon(
                        (today.isAtSameMomentAs(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)) || 
                         today.isAfter(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)))
                            ? Icons.lock_open
                            : Icons.lock,
                        size: 40,
                        color: (today.isAtSameMomentAs(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)) || 
                                today.isAfter(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)))
                            ? Colors.green
                            : Colors.grey,
                      ),
                      title: Text(
                        latestCapsule.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        'เปิดวันที่ ${latestCapsule.openDate.day.toString().padLeft(2, '0')}/${latestCapsule.openDate.month.toString().padLeft(2, '0')}/${latestCapsule.openDate.year}\n${((today.isAtSameMomentAs(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)) || 
                          today.isAfter(DateTime(latestCapsule.openDate.year, latestCapsule.openDate.month, latestCapsule.openDate.day)))
                            ? '🔓 Unlocked'
                            : '🔒 Locked')}',
                      ),
                      isThreeLine: true,
                      onTap: () async {
                        await context.push('/capsules/detail', extra: latestCapsule);
                        setState(() {
                          _fetchCapsules();
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
