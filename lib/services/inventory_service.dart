import 'dart:convert';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Envanter servisi — power-up kullanımı (extra_move vb.).
class InventoryService {
  final LocalStorage _storage;

  InventoryService(this._storage);

  /// Tüm sahip olunan öğeler.
  Map<String, int> _loadOwned() {
    try {
      final json = _storage.inventoryJson;
      if (json != null) {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return map.map((k, v) => MapEntry(k, v as int));
      }
    } catch (e) {
      AppLogger.error('Envanter yüklenirken hata', error: e);
    }
    return {};
  }

  /// Belirli bir öğeye sahip mi?
  bool ownsItem(String itemId) {
    final owned = _loadOwned();
    return (owned[itemId] ?? 0) > 0;
  }

  /// Power-up kullan.
  Future<bool> usePowerUp(String itemId) async {
    final owned = _loadOwned();
    final qty = owned[itemId] ?? 0;
    if (qty <= 0) return false;

    owned[itemId] = qty - 1;
    await _storage.setInventoryJson(jsonEncode(owned));
    AppLogger.info('Power-up kullanıldı: $itemId (kalan: ${qty - 1})');
    return true;
  }

  /// Belirli bir power-up'ın kaç tane olduğu.
  int getPowerUpCount(String itemId) {
    final owned = _loadOwned();
    return owned[itemId] ?? 0;
  }
}
