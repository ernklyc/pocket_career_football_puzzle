import 'dart:convert';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/shop_item.dart';
import 'package:pocket_career_football_puzzle/domain/entities/transaction.dart';
import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';
import 'package:pocket_career_football_puzzle/services/currency_service.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Envanter ve mağaza servisi.
class InventoryService {
  final LocalStorage _storage;
  final CurrencyService _currencyService;

  InventoryService(this._storage, this._currencyService);

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

  /// Mağaza öğelerini yükle (owned bilgisiyle).
  List<ShopItem> getShopItems() {
    final owned = _loadOwned();
    return EconomyConfig.shopItems.values.map((config) {
      final ownedQty = owned[config.id] ?? 0;
      return ShopItem(
        id: config.id,
        type: config.type,
        coinPrice: config.coinPrice,
        nameKey: config.nameKey,
        descriptionKey: config.descriptionKey,
        isOwned: ownedQty > 0,
        quantity: ownedQty,
      );
    }).toList();
  }

  /// Öğe satın al.
  Future<bool> purchaseItem(String itemId) async {
    final config = EconomyConfig.shopItems[itemId];
    if (config == null) {
      AppLogger.warning('Bilinmeyen item: $itemId');
      return false;
    }

    // Cosmetic ürünler sadece bir kez alınabilir
    if (config.type == ShopItemType.cosmetic || config.type == ShopItemType.unlock) {
      final owned = _loadOwned();
      if ((owned[itemId] ?? 0) > 0) {
        AppLogger.warning('Item zaten sahip olunan: $itemId');
        return false;
      }
    }

    // Coin kontrolü ve harcama
    final success = await _currencyService.spendCoins(
      amount: config.coinPrice,
      reason: 'shop_purchase_$itemId',
      source: TransactionSource.shopPurchase,
    );

    if (!success) return false;

    // Envantere ekle
    final owned = _loadOwned();
    owned[itemId] = (owned[itemId] ?? 0) + 1;
    await _storage.setInventoryJson(jsonEncode(owned));

    AppLogger.info('Item satın alındı: $itemId');
    return true;
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
