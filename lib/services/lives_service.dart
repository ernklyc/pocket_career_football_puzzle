import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Can sistemi: max 10 can, saatte 1 can dolar.
class LivesService {
  final LocalStorage _storage;

  static const int maxLives = 10;
  static const Duration regenInterval = Duration(hours: 1);

  LivesService(this._storage);

  /// Mevcut can sayısı (rejenere edilmiş haliyle). Regen gerekirse kaydeder.
  Future<int> getLives() async {
    int count = _storage.livesCount;
    final lastMs = _storage.lastLifeRegenTimeMs;
    final now = DateTime.now();

    if (lastMs != null && count < maxLives) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      final elapsed = now.difference(last);
      final fullIntervals = elapsed.inMinutes ~/ regenInterval.inMinutes;
      if (fullIntervals > 0) {
        count = (count + fullIntervals).clamp(0, maxLives);
        await _storage.setLivesCount(count);
        await _storage.setLastLifeRegenTime(now.millisecondsSinceEpoch);
      }
    }

    return count;
  }

  /// Senkron okuma (regen uygulanmamış, sadece depodaki değer). UI anlık göstermek için.
  int get livesSync => _storage.livesCount;

  /// Bir can harca. Başarılı ise true.
  Future<bool> spendLife() async {
    final current = await getLives();
    if (current <= 0) {
      AppLogger.info('Can yok, oyun başlatılamıyor');
      return false;
    }
    final newCount = current - 1;
    await _storage.setLivesCount(newCount);
    await _storage.setLastLifeRegenTime(DateTime.now().millisecondsSinceEpoch);
    AppLogger.info('Can harcandı: $current -> $newCount');
    return true;
  }

  /// Bir sonraki can dolumuna kalan süre (dolu ise null). Regen uygulanmamış count kullanır.
  Duration? get timeUntilNextRegen {
    final count = _storage.livesCount;
    if (count >= maxLives) return null;

    final lastMs = _storage.lastLifeRegenTimeMs;
    if (lastMs == null) return regenInterval;

    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    final elapsed = DateTime.now().difference(last);
    final remaining = regenInterval - elapsed;
    if (remaining <= Duration.zero) return Duration.zero;
    return remaining;
  }
}
