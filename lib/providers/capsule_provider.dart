import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/capsule.dart';
import '../services/capsule_service.dart';

// ── Service Provider ──────────────────────────────────────────────────────────
final capsuleServiceProvider = Provider<CapsuleService>((ref) => CapsuleService());

// ── Stats ─────────────────────────────────────────────────────────────────────
final capsuleStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(capsuleServiceProvider).getStats();
});

// ── Next Capsule to Open ──────────────────────────────────────────────────────
final nextCapsuleProvider = FutureProvider<Capsule?>((ref) async {
  return ref.watch(capsuleServiceProvider).getNextToOpen();
});

// ── Full Capsule List (Notifier) ─────────────────────────────────────────
class CapsuleNotifier extends Notifier<AsyncValue<List<Capsule>>> {
  @override
  AsyncValue<List<Capsule>> build() {
    Future.microtask(() => loadCapsules());
    return const AsyncValue.loading();
  }

  CapsuleService get _service => ref.read(capsuleServiceProvider);

  Future<void> loadCapsules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getCapsules());
  }

  Future<void> createCapsule({
    required String title,
    required String message,
    required CapsuleType type,
    CapsuleVisibility visibility = CapsuleVisibility.private,
    DateTime? openDate,
    double? latitude,
    double? longitude,
    int radiusMeters = 100,
    bool isSurprise = false,
    String? mood,
  }) async {
    await _service.createCapsule(
      title: title,
      message: message,
      type: type,
      visibility: visibility,
      openDate: openDate,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      isSurprise: isSurprise,
      mood: mood,
    );
    await loadCapsules();
  }

  Future<void> markAsOpened(String id) async {
    await _service.markAsOpened(id);
    await loadCapsules();
  }

  Future<void> deleteCapsule(String id) async {
    await _service.deleteCapsule(id);
    await loadCapsules();
  }

  List<Capsule> get locked =>
      state.value?.where((c) => !c.isUnlocked).toList() ?? [];

  List<Capsule> get unlocked =>
      state.value?.where((c) => c.isUnlocked).toList() ?? [];

  List<Capsule> get shared =>
      state.value
          ?.where((c) => c.type == CapsuleType.friend)
          .toList() ??
      [];

  List<Capsule> byType(CapsuleType type) =>
      state.value?.where((c) => c.type == type).toList() ?? [];
}

final capsuleProvider =
    NotifierProvider<CapsuleNotifier, AsyncValue<List<Capsule>>>(CapsuleNotifier.new);

// ── Public Capsules ───────────────────────────────────────────────────────────
final publicCapsulesProvider = FutureProvider<List<Capsule>>((ref) async {
  return ref.watch(capsuleServiceProvider).getPublicCapsules();
});
