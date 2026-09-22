import '../models/capsule.dart';
import '../services/capsule_service.dart';

/// Repository layer that adds domain-level filtering on top of CapsuleService
class CapsuleRepository {
  final CapsuleService _service;

  CapsuleRepository(this._service);

  Future<List<Capsule>> getAllCapsules() => _service.getCapsules();

  Future<List<Capsule>> getLockedCapsules() async {
    final all = await _service.getCapsules();
    return all.where((c) => !c.isUnlocked).toList();
  }

  Future<List<Capsule>> getUnlockedCapsules() async {
    final all = await _service.getCapsules();
    return all.where((c) => c.isUnlocked).toList();
  }

  Future<List<Capsule>> getSharedCapsules() async {
    final all = await _service.getCapsules();
    return all.where((c) => c.type == CapsuleType.friend).toList();
  }

  Future<List<Capsule>> getPublicCapsules() => _service.getPublicCapsules();

  Future<Capsule?> getCapsule(String id) => _service.getCapsule(id);

  Future<void> openCapsule(String id) => _service.markAsOpened(id);

  Future<void> deleteCapsule(String id) => _service.deleteCapsule(id);

  Future<Map<String, int>> getStats() => _service.getStats();
}
