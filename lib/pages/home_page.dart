import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                    onPressed: () {},
                    child: const Text('สร้าง Capsule'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Capsule ของฉัน',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // Empty state
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
            ),
          ],
        ),
      ),
    );
  }
}
