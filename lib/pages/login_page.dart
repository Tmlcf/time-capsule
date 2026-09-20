import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Time Capsule')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Placeholder for actual login logic
            context.go('/home');
          },
          child: const Text('Login to Enter'),
        ),
      ),
    );
  }
}
