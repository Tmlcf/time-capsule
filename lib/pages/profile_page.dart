import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User Profile Details'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
