import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';

/// Reklam durumu.
enum AdState { idle, loading, ready, showing, completed, failed, cancelled }

/// Reklam servisi (AdMob).
/// SDK entegrasyonu production'da yapılacak, şimdilik stub.
/// Sadece ödüllü reklam desteklenir; banner kaldırıldı.
class AdsService {
  final LocalStorage _storage;
  bool _initialized = false;
  AdState _rewardedState = AdState.idle;

  AdsService(this._storage);

  AdState get rewardedState => _rewardedState;

  /// SDK'yı başlat.
  Future<void> initialize() async {
    try {
      // TODO: MobileAds.instance.initialize()
      _initialized = true;
      AppLogger.sdk('AdMob', 'Initialized (stub mode)');
    } catch (e) {
      AppLogger.error('AdMob initialization failed', error: e);
    }
  }

  /// Premium durumu güncelle (no-op, banner kaldırıldı).
  void setPremiumActive(bool active) {
    // Banner kaldırıldı, tutuluyor paywall uyumluluğu için.
  }

  /// Ödüllü reklam yükle.
  Future<void> loadRewarded() async {
    if (!_initialized) return;
    _rewardedState = AdState.loading;
    // TODO: Gerçek rewarded yükleme
    await Future.delayed(const Duration(milliseconds: 500));
    _rewardedState = AdState.ready;
    AppLogger.sdk('AdMob', 'Rewarded loaded (stub)');
  }

  /// Ödüllü reklam gösterilmeye hazır mı?
  bool get isRewardedReady => _rewardedState == AdState.ready;

  /// Ödüllü reklam cooldown kontrolü.
  bool get isRewardedOnCooldown {
    final lastWatch = _storage.rewardedAdLastWatch;
    if (lastWatch == null) return false;
    return DateTime.now().difference(lastWatch) < EconomyConfig.rewardedAdCooldown;
  }

  /// Günlük limit kontrolü.
  bool get isRewardedDailyLimitReached {
    return _storage.rewardedAdDailyCount >= EconomyConfig.rewardedAdDailyLimit;
  }

  /// Ödüllü reklam gösterilebilir mi?
  bool get canShowRewarded {
    return isRewardedReady && !isRewardedOnCooldown && !isRewardedDailyLimitReached;
  }

  /// Ödüllü reklam göster.
  Future<bool> showRewarded() async {
    if (!canShowRewarded) return false;

    _rewardedState = AdState.showing;
    // TODO: Gerçek rewarded gösterme
    await Future.delayed(const Duration(seconds: 1));

    // Stub: her zaman tamamlanmış say
    _rewardedState = AdState.completed;
    await _storage.setRewardedAdLastWatch(DateTime.now());
    await _storage.incrementRewardedAdCount();

    AppLogger.sdk('AdMob', 'Rewarded completed (stub)');

    // Yeni reklam yükle
    await loadRewarded();
    return true;
  }

  void dispose() {
    _rewardedState = AdState.idle;
  }
}
