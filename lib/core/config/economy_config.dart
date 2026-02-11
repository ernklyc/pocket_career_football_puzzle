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

  // Mağaza item fiyatları
  static const Map<String, ShopItemConfig> shopItems = {
    'extra_move': ShopItemConfig(
      id: 'extra_move',
      type: ShopItemType.powerUp,
      coinPrice: 50,
      nameKey: 'shop_extra_move',
      descriptionKey: 'shop_extra_move_desc',
    ),
    'reset_level': ShopItemConfig(
      id: 'reset_level',
      type: ShopItemType.powerUp,
      coinPrice: 40,
      nameKey: 'shop_reset_level',
      descriptionKey: 'shop_reset_level_desc',
    ),
    'jersey_1': ShopItemConfig(
      id: 'jersey_1',
      type: ShopItemType.cosmetic,
      coinPrice: 100,
      nameKey: 'shop_jersey_1',
      descriptionKey: 'shop_jersey_1_desc',
    ),
    'boot_1': ShopItemConfig(
      id: 'boot_1',
      type: ShopItemType.cosmetic,
      coinPrice: 80,
      nameKey: 'shop_boot_1',
      descriptionKey: 'shop_boot_1_desc',
    ),
    'badge_1': ShopItemConfig(
      id: 'badge_1',
      type: ShopItemType.cosmetic,
      coinPrice: 120,
      nameKey: 'shop_badge_1',
      descriptionKey: 'shop_badge_1_desc',
    ),
    'trophy_slot': ShopItemConfig(
      id: 'trophy_slot',
      type: ShopItemType.unlock,
      coinPrice: 150,
      nameKey: 'shop_trophy_slot',
      descriptionKey: 'shop_trophy_slot_desc',
    ),
    // Top skin'leri
    'gold_ball': ShopItemConfig(
      id: 'gold_ball',
      type: ShopItemType.cosmetic,
      coinPrice: 200,
      nameKey: 'Altın Top',
      descriptionKey: 'Parlak altın top skin\'i',
    ),
    'fire_ball': ShopItemConfig(
      id: 'fire_ball',
      type: ShopItemType.cosmetic,
      coinPrice: 250,
      nameKey: 'Ateş Top',
      descriptionKey: 'Ateşli kırmızı top',
    ),
    'ice_ball': ShopItemConfig(
      id: 'ice_ball',
      type: ShopItemType.cosmetic,
      coinPrice: 250,
      nameKey: 'Buz Top',
      descriptionKey: 'Buz mavisi top',
    ),
    'neon_ball': ShopItemConfig(
      id: 'neon_ball',
      type: ShopItemType.cosmetic,
      coinPrice: 300,
      nameKey: 'Neon Top',
      descriptionKey: 'Parlak neon yeşil top',
    ),
    // Blok temaları
    'wood_theme': ShopItemConfig(
      id: 'wood_theme',
      type: ShopItemType.cosmetic,
      coinPrice: 180,
      nameKey: 'Ahşap Tema',
      descriptionKey: 'Ahşap blok teması',
    ),
    'metal_theme': ShopItemConfig(
      id: 'metal_theme',
      type: ShopItemType.cosmetic,
      coinPrice: 220,
      nameKey: 'Metal Tema',
      descriptionKey: 'Metalik blok teması',
    ),
    'candy_theme': ShopItemConfig(
      id: 'candy_theme',
      type: ShopItemType.cosmetic,
      coinPrice: 280,
      nameKey: 'Şeker Tema',
      descriptionKey: 'Renkli şeker blok teması',
    ),
    // Profil rozetleri
    'badge_champion': ShopItemConfig(
      id: 'badge_champion',
      type: ShopItemType.cosmetic,
      coinPrice: 150,
      nameKey: 'Şampiyon Rozeti',
      descriptionKey: 'Profiline şampiyon rozeti ekle',
    ),
    'badge_fire': ShopItemConfig(
      id: 'badge_fire',
      type: ShopItemType.cosmetic,
      coinPrice: 120,
      nameKey: 'Ateş Rozeti',
      descriptionKey: 'Ateşli profil rozeti',
    ),
  };
}

enum ShopItemType { powerUp, cosmetic, unlock }

class ShopItemConfig {
  final String id;
  final ShopItemType type;
  final int coinPrice;
  final String nameKey;
  final String descriptionKey;

  const ShopItemConfig({
    required this.id,
    required this.type,
    required this.coinPrice,
    required this.nameKey,
    required this.descriptionKey,
  });
}
