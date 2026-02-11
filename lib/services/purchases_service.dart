import 'package:pocket_career_football_puzzle/core/logging/logger.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';

/// Satın alma durumu.
enum PurchaseState { idle, loading, purchasing, success, failed, cancelled }

/// Coin paketi.
class CoinPackOffering {
  final String id;
  final String title;
  final int coins;
  final String price;

  const CoinPackOffering({
    required this.id,
    required this.title,
    required this.coins,
    required this.price,
  });
}

/// Reklam kaldırma teklifi.
class RemoveAdsOffering {
  final String id;
  final String title;
  final String price;
  final bool isOwned;

  const RemoveAdsOffering({
    required this.id,
    required this.title,
    required this.price,
    required this.isOwned,
  });
}

/// Satın alma servisi (RevenueCat).
/// SDK entegrasyonu production'da yapılacak, şimdilik stub.
class PurchasesService {
  final LocalStorage _storage;
  bool _initialized = false;
  PurchaseState _state = PurchaseState.idle;

  PurchasesService(this._storage);

  PurchaseState get state => _state;
  bool get isPremium => _storage.cachedPremium;

  /// SDK'yı başlat.
  Future<void> initialize() async {
    try {
      // TODO: Purchases.configure(PurchasesConfiguration(apiKey))
      _initialized = true;
      await _reconcileEntitlements();
      AppLogger.sdk('RevenueCat', 'Initialized (stub mode)');
    } catch (e) {
      AppLogger.error('RevenueCat initialization failed', error: e);
    }
  }

  /// Entitlement'ları kontrol et ve senkronize et.
  Future<void> _reconcileEntitlements() async {
    try {
      // TODO: Gerçek RevenueCat entitlement kontrolü
      // Şimdilik cached değeri kullan
      AppLogger.sdk('RevenueCat', 'Entitlements reconciled (stub)');
    } catch (e) {
      AppLogger.error('Entitlement reconciliation failed', error: e);
    }
  }

  /// Coin paketlerini getir.
  Future<List<CoinPackOffering>> getCoinOfferings() async {
    // TODO: Gerçek RevenueCat offerings
    return const [
      CoinPackOffering(id: 'coins_small', title: 'Small Pack', coins: 500, price: '₺29.99'),
      CoinPackOffering(id: 'coins_medium', title: 'Medium Pack', coins: 1200, price: '₺59.99'),
      CoinPackOffering(id: 'coins_large', title: 'Large Pack', coins: 3000, price: '₺99.99'),
    ];
  }

  /// Reklam kaldırma teklifini getir.
  Future<RemoveAdsOffering> getRemoveAdsOffering() async {
    // TODO: Gerçek RevenueCat offerings
    return RemoveAdsOffering(
      id: 'remove_ads',
      title: 'Remove Ads',
      price: '₺49.99',
      isOwned: isPremium,
    );
  }

  /// Coin paketi satın al.
  Future<bool> purchaseCoinPack(String packId) async {
    if (!_initialized) return false;

    _state = PurchaseState.purchasing;
    try {
      // TODO: Gerçek RevenueCat purchase
      await Future.delayed(const Duration(seconds: 1));

      _state = PurchaseState.success;
      AppLogger.sdk('RevenueCat', 'Coin pack purchased: $packId (stub)');
      return true;
    } catch (e) {
      _state = PurchaseState.failed;
      AppLogger.error('Coin pack purchase failed', error: e);
      return false;
    }
  }

  /// Reklam kaldır satın al.
  Future<bool> purchaseRemoveAds() async {
    if (!_initialized) return false;

    _state = PurchaseState.purchasing;
    try {
      // TODO: Gerçek RevenueCat purchase
      await Future.delayed(const Duration(seconds: 1));

      await _storage.setCachedPremium(true);
      _state = PurchaseState.success;
      AppLogger.sdk('RevenueCat', 'Remove ads purchased (stub)');
      return true;
    } catch (e) {
      _state = PurchaseState.failed;
      AppLogger.error('Remove ads purchase failed', error: e);
      return false;
    }
  }

  /// Satın alımları geri yükle.
  Future<bool> restorePurchases() async {
    try {
      // TODO: Gerçek RevenueCat restore
      await Future.delayed(const Duration(seconds: 1));
      AppLogger.sdk('RevenueCat', 'Purchases restored (stub)');
      return true;
    } catch (e) {
      AppLogger.error('Restore purchases failed', error: e);
      return false;
    }
  }
}
