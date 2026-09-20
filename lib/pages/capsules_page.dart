import 'package:flutter/material.dart';

class CapsulesPage extends StatelessWidget {
  const CapsulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Capsules')),
      body: const Center(
        child: Text('List of your Time Capsules.'),
      ),
    );
  }
}
