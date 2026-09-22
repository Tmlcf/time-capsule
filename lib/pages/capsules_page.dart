import 'package:flutter/material.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';
import 'package:time_capsule/widgets/capsule_card.dart';

class CapsulesPage extends StatefulWidget {
  const CapsulesPage({super.key});

  @override
  State<CapsulesPage> createState() => _CapsulesPageState();
}

class _CapsulesPageState extends State<CapsulesPage>
    with SingleTickerProviderStateMixin {
  final CapsuleService _capsuleService = CapsuleService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Capsules',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.inbox_outlined),
              text: '\u0e02\u0e2d\u0e07\u0e09\u0e31\u0e19',
            ),
            Tab(
              icon: Icon(Icons.mail_outline),
              text: '\u0e2a\u0e48\u0e07\u0e16\u0e36\u0e07\u0e09\u0e31\u0e19',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyCapsulesList(capsuleService: _capsuleService),
          _ReceivedCapsulesList(capsuleService: _capsuleService),
        ],
      ),
    );
  }
}

// Tab 1
class _MyCapsulesList extends StatefulWidget {
  final CapsuleService capsuleService;
  const _MyCapsulesList({required this.capsuleService});

  @override
  State<_MyCapsulesList> createState() => _MyCapsulesListState();
}

class _MyCapsulesListState extends State<_MyCapsulesList> {
  late Future<List<Capsule>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.capsuleService.getCapsules();
  }

  void _refresh() {
    setState(() {
      _future = widget.capsuleService.getCapsules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Capsule>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(
                  '\u0e42\u0e2b\u0e25\u0e14\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e44\u0e21\u0e48\u0e2a\u0e33\u0e40\u0e23\u0e47\u0e08',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
        final capsules = snapshot.data ?? [];
        if (capsules.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  '\u0e22\u0e31\u0e07\u0e44\u0e21\u0e48\u0e21\u0e35 Capsule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\u0e2a\u0e23\u0e49\u0e32\u0e07 Capsule \u0e41\u0e23\u0e01\u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e40\u0e23\u0e34\u0e48\u0e21\u0e40\u0e01\u0e47\u0e1a\u0e04\u0e27\u0e32\u0e21\u0e17\u0e23\u0e07\u0e08\u0e33',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: capsules.length,
            itemBuilder: (context, index) =>
                CapsuleCard(capsule: capsules[index]),
          ),
        );
      },
    );
  }
}

// Tab 2
class _ReceivedCapsulesList extends StatefulWidget {
  final CapsuleService capsuleService;
  const _ReceivedCapsulesList({required this.capsuleService});

  @override
  State<_ReceivedCapsulesList> createState() =>
      _ReceivedCapsulesListState();
}

class _ReceivedCapsulesListState extends State<_ReceivedCapsulesList> {
  late Future<List<Capsule>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.capsuleService.getReceivedCapsules();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Capsule>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text(
                  '\u0e42\u0e2b\u0e25\u0e14\u0e02\u0e49\u0e2d\u0e21\u0e39\u0e25\u0e44\u0e21\u0e48\u0e2a\u0e33\u0e40\u0e23\u0e47\u0e08',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }
        final capsules = snapshot.data ?? [];
        if (capsules.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mail_outline,
                    size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  '\u0e22\u0e31\u0e07\u0e44\u0e21\u0e48\u0e21\u0e35 Capsule \u0e17\u0e35\u0e48\u0e2a\u0e48\u0e07\u0e16\u0e36\u0e07\u0e04\u0e38\u0e13',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\u0e40\u0e21\u0e37\u0e48\u0e2d\u0e40\u0e1e\u0e37\u0e48\u0e2d\u0e19\u0e2a\u0e48\u0e07 Capsule \u0e43\u0e2b\u0e49\u0e04\u0e38\u0e13 \u0e08\u0e30\u0e41\u0e2a\u0e14\u0e07\u0e17\u0e35\u0e48\u0e19\u0e35\u0e48',
                  style: TextStyle(color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: capsules.length,
          itemBuilder: (context, index) => CapsuleCard(
            capsule: capsules[index],
            isReceived: true,
          ),
        );
      },
    );
  }
}
