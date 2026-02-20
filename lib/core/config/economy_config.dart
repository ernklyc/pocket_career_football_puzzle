/// Ekonomi ve coin sistemi konfigürasyonu.
/// Tüm coin miktarları ve fiyatlar burada tanımlanır.
class EconomyConfig {
  EconomyConfig._();

  // Başlangıç bakiyesi
  static const int initialCoinBalance = 100;

  // Level tamamlama ödülleri
  static const int levelCompleteBaseReward = 10;
  static const int perfectLevelBonus = 25;

  // Puan formülü
  static const int baseScore = 100;
  static const double levelDifficultyMultiplier = 1.15;
  static const int remainingMoveBonusPerMove = 50;
  static const int unnecessaryMovePenalty = 10;

  // Ödüllü reklam
  static const int rewardedAdCoinGrant = 20;
  static const int rewardedAdDailyLimit = 5;
  static const Duration rewardedAdCooldown = Duration(minutes: 5);

  // IAP Coin paketleri
  static const int coinPackSmall = 500;
  static const int coinPackMedium = 1200;
  static const int coinPackLarge = 3000;
}
