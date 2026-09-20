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

  bool _isUnlocked(Capsule capsule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final openDate = DateTime(
      capsule.openDate.year,
      capsule.openDate.month,
      capsule.openDate.day,
    );
    return today.isAtSameMomentAs(openDate) || today.isAfter(openDate);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
            onPressed: () => setState(() => _fetchCapsules()),
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
          // ─── Loading ───
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ─── Error ───
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'ไม่สามารถโหลดข้อมูล Capsule ได้',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ลองใหม่อีกครั้ง',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _fetchCapsules()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('ลองใหม่'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ─── Data ───
          final capsules = snapshot.data ?? [];
          final int total = capsules.length;
          final int unlocked = capsules.where(_isUnlocked).length;
          final int locked = total - unlocked;
          final Capsule? latestCapsule = capsules.isNotEmpty ? capsules.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Greeting ───
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

                // ─── Stats Card ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('ทั้งหมด', total, Colors.blue),
                      _buildDivider(),
                      _buildStatCard('🔒 Locked', locked, Colors.grey.shade700),
                      _buildDivider(),
                      _buildStatCard('🔓 Unlocked', unlocked, Colors.green),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Create Banner ───
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
                          setState(() => _fetchCapsules());
                        },
                        child: const Text('สร้าง Capsule'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ─── Latest Capsule ───
                const Text(
                  'Latest Capsule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                if (latestCapsule == null)
                  // ─── Empty State ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 50, color: Colors.grey.shade500),
                        const SizedBox(height: 12),
                        Text(
                          'ยังไม่มี Time Capsule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'สร้างข้อความถึงอนาคตของคุณดู ⏳',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                else
                  // ─── Latest Capsule Card ───
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _isUnlocked(latestCapsule)
                            ? Colors.green.shade100
                            : Colors.grey.shade200,
                        child: Icon(
                          _isUnlocked(latestCapsule) ? Icons.lock_open : Icons.lock,
                          color: _isUnlocked(latestCapsule) ? Colors.green : Colors.grey.shade700,
                        ),
                      ),
                      title: Text(
                        latestCapsule.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('เปิดวันที่ ${_formatDate(latestCapsule.openDate)}'),
                            const SizedBox(height: 4),
                            Text(
                              _isUnlocked(latestCapsule) ? '🔓 Unlocked' : '🔒 Locked',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isUnlocked(latestCapsule) ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.push('/capsules/detail', extra: latestCapsule);
                        setState(() => _fetchCapsules());
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

  Widget _buildStatCard(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }
}
