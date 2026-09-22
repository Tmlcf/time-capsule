import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/models/capsule.dart';
import 'package:time_capsule/services/capsule_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CapsuleService _capsuleService = CapsuleService();

  late Future<List<Capsule>> _capsulesFuture;

  static const Color _background = Color(0xFF0B0B1E);
  static const Color _surface = Color(0xFF15152B);
  static const Color _purpleLight = Color(0xFF9C6CFF);

  @override
  void initState() {
    super.initState();
    _capsulesFuture = _fetchCapsules();
  }

  Future<List<Capsule>> _fetchCapsules() async {
    return _capsuleService.getCapsules();
  }

  Future<void> _refresh() async {
    setState(() {
      _capsulesFuture = _fetchCapsules();
    });

    await _capsulesFuture;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _purpleLight,
          backgroundColor: _surface,
          onRefresh: _refresh,
          child: FutureBuilder<List<Capsule>>(
            future: _capsulesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _HomeLoading();
              }

              if (snapshot.hasError) {
                return _HomeError(onRetry: _refresh);
              }

              final capsules = snapshot.data ?? [];

              return _HomeContent(capsules: capsules, formatDate: _formatDate);
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<Capsule> capsules;
  final String Function(DateTime?) formatDate;

  const _HomeContent({required this.capsules, required this.formatDate});

  static const Color surface = Color(0xFF15152B);
  static const Color purple = Color(0xFF651FFF);
  static const Color purpleLight = Color(0xFF9C6CFF);
  static const Color textSecondary = Color(0xFFA8A7C0);

  @override
  Widget build(BuildContext context) {
    final total = capsules.length;

    final latestCapsule = capsules.isEmpty ? null : capsules.first;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _buildTopBar(context),
        const SizedBox(height: 28),

        _buildHero(context),
        const SizedBox(height: 24),

        _buildStats(total),
        const SizedBox(height: 28),

        _buildCreateButton(context),
        const SizedBox(height: 30),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest Capsule',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (capsules.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/capsules'),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: purpleLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        if (latestCapsule == null)
          _buildEmptyState(context)
        else
          _buildLatestCapsule(context, latestCapsule),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [purple, Color(0xFF9C6CFF)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: purple.withValues(alpha: 0.35),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),

        const SizedBox(width: 13),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIME CAPSULE',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                  letterSpacing: 2.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your memories, preserved.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF292942)),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35146B), Color(0xFF211743), Color(0xFF111126)],
        ),
        border: Border.all(color: purple.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: 0.16),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: 0.12),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: purpleLight,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'YOUR DIGITAL MEMORY',
                      style: TextStyle(
                        color: purpleLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 21),

              const Text(
                'Save today.\nOpen it in the future.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Create a capsule and leave a memory for your future self.',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 21),

              GestureDetector(
                onTap: () => context.push('/create'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withValues(alpha: 0.3),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 7),
                      Text(
                        'Create capsule',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2_outlined,
            value: '$total',
            label: 'Capsules',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.auto_awesome_rounded,
            value: total > 0 ? 'Ready' : '0',
            label: 'Memories',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.favorite_border_rounded,
            value: total > 0 ? 'Active' : '—',
            label: 'Status',
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/create'),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFF2B2B4A)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF32106B), Color(0xFF21133F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: purpleLight,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a new memory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Write something for your future self',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestCapsule(BuildContext context, Capsule capsule) {
    return GestureDetector(
      onTap: () {
        context.push('/capsules/detail', extra: capsule);
      },
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: purple.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [purple, purpleLight]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(23)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: purpleLight,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 13),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LATEST MEMORY',
                              style: TextStyle(
                                color: purpleLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Your saved moment',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: textSecondary,
                        size: 16,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    capsule.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D1D3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: purpleLight,
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          formatDate(capsule.createdAt),
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF292942)),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty_rounded,
              color: purpleLight,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No capsules yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your first memory is waiting to be created.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.5),
          ),

          const SizedBox(height: 18),

          TextButton(
            onPressed: () => context.push('/create'),
            child: const Text(
              'Create your first capsule',
              style: TextStyle(color: purpleLight, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  static const Color surface = Color(0xFF15152B);
  static const Color purpleLight = Color(0xFF9C6CFF);
  static const Color textSecondary = Color(0xFFA8A7C0);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF292942)),
      ),
      child: Column(
        children: [
          Icon(icon, color: purpleLight, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF9C6CFF)),
    );
  }
}

class _HomeError extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _HomeError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFA8A7C0),
              size: 48,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load capsules',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Something went wrong. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFA8A7C0), fontSize: 13),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF651FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
