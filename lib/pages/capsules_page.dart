import 'package:flutter/material.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';
import 'package:time_capsule/widgets/capsule_card.dart';

const Color _backgroundColor = Color(0xFF0B0B1E);
const Color _surfaceColor = Color(0xFF15152B);
const Color _primaryColor = Colors.deepPurpleAccent;

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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Capsules',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.inventory_2_outlined, size: 20),
                  text: 'ของฉัน',
                ),
                Tab(
                  icon: Icon(Icons.mail_outline, size: 20),
                  text: 'ส่งถึงฉัน',
                ),
              ],
            ),
          ),
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

// ============================================================
// My Capsules
// ============================================================

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

  Future<void> _refresh() async {
    setState(() {
      _future = widget.capsuleService.getCapsules();
    });

    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Capsule>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        if (snapshot.hasError) {
          return _ErrorState(onRetry: _refresh);
        }

        final capsules = snapshot.data ?? [];

        if (capsules.isEmpty) {
          return RefreshIndicator(
            color: _primaryColor,
            backgroundColor: _surfaceColor,
            onRefresh: _refresh,
            child: const _EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'ยังไม่มี Capsule',
              message: 'สร้าง Capsule แรกเพื่อเริ่มเก็บความทรงจำ',
            ),
          );
        }

        return RefreshIndicator(
          color: _primaryColor,
          backgroundColor: _surfaceColor,
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            itemCount: capsules.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return CapsuleCard(capsule: capsules[index]);
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// Received Capsules
// ============================================================

class _ReceivedCapsulesList extends StatefulWidget {
  final CapsuleService capsuleService;

  const _ReceivedCapsulesList({required this.capsuleService});

  @override
  State<_ReceivedCapsulesList> createState() => _ReceivedCapsulesListState();
}

class _ReceivedCapsulesListState extends State<_ReceivedCapsulesList> {
  late Future<List<Capsule>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.capsuleService.getReceivedCapsules();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.capsuleService.getReceivedCapsules();
    });

    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Capsule>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingState();
        }

        if (snapshot.hasError) {
          return _ErrorState(onRetry: _refresh);
        }

        final capsules = snapshot.data ?? [];

        if (capsules.isEmpty) {
          return RefreshIndicator(
            color: _primaryColor,
            backgroundColor: _surfaceColor,
            onRefresh: _refresh,
            child: const _EmptyState(
              icon: Icons.mail_outline,
              title: 'ยังไม่มี Capsule ที่ส่งถึงคุณ',
              message: 'เมื่อเพื่อนส่ง Capsule ให้คุณ จะปรากฏที่นี่',
            ),
          );
        }

        return RefreshIndicator(
          color: _primaryColor,
          backgroundColor: _surfaceColor,
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            itemCount: capsules.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return CapsuleCard(capsule: capsules[index], isReceived: true);
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// Loading State
// ============================================================

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          SizedBox(height: 16),
          Text(
            'กำลังโหลด Capsule...',
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Error State
// ============================================================

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'โหลดข้อมูลไม่สำเร็จ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'กรุณาตรวจสอบการเชื่อมต่อแล้วลองใหม่อีกครั้ง',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _primaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 46, color: _primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
