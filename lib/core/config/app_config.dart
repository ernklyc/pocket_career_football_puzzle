/// Uygulama genelinde sabit konfigürasyon değerleri.
class AppConfig {
  AppConfig._();

  // Uygulama bilgileri
  static const String appName = 'Pocket Career: Football Puzzle';
  static const String appVersion = '1.0.0';
  static const int schemaVersion = 1;

  // Sezon & Level
  static const int levelsPerSeason = 25;
  static const int initialSeason = 1;

  // Oyun
  static const int defaultTargetSessionSeconds = 90;
  static const int baseScore = 100;
  static const double bonusMultiplier = 1.5;

  // Grid boyutları (bulmaca)
  static const int minGridSize = 5;
  static const int maxGridSize = 9;

  // Takımlar (sadece bu 5 logo: assets/pp/*.png)
  static const List<TeamConfig> availableTeams = [
    TeamConfig(id: 'galatasaray', name: 'Galatasaray', primaryColor: 0xFFFF4500, secondaryColor: 0xFFFFD700, logoEmoji: '🟡', logoAssetPath: 'assets/pp/sari_kirmizi.png'),
    TeamConfig(id: 'fenerbahce', name: 'Fenerbahçe', primaryColor: 0xFF0000CD, secondaryColor: 0xFFFFD700, logoEmoji: '🟡', logoAssetPath: 'assets/pp/sari_lacivert.png'),
    TeamConfig(id: 'besiktas', name: 'Beşiktaş', primaryColor: 0xFF000000, secondaryColor: 0xFFFFFFFF, logoEmoji: '⬛', logoAssetPath: 'assets/pp/siyah_beyaz.png'),
    TeamConfig(id: 'trabzonspor', name: 'Trabzonspor', primaryColor: 0xFF8B0000, secondaryColor: 0xFF00008B, logoEmoji: '🔵', logoAssetPath: 'assets/pp/bordo_mavi.png'),
    TeamConfig(id: 'real_madrid', name: 'Real Madrid', primaryColor: 0xFFFFFFFF, secondaryColor: 0xFF00529F, logoEmoji: '👑', logoAssetPath: 'assets/pp/kirmizi_beyaz.png'),
  ];

  // Mevkiler
  static const List<String> positions = [
    'Kaleci',
    'Defans',
    'Orta Saha',
    'Forvet',
  ];

  // Feature flags
  static const bool leaderboardEnabled = true;
  static const bool notificationsEnabled = true;
  static const bool cloudSyncEnabled = false;
  static const bool rewardedContinueEnabled = true;

  // Legal
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
}

class TeamConfig {
  final String id;
  final String name;
  final int primaryColor;
  final int secondaryColor;
  final String logoEmoji;
  /// Profil logosu görseli (assets/pp/*.png). Yoksa logoEmoji kullanılır.
  final String? logoAssetPath;

  const TeamConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    this.logoEmoji = '⚽',
    this.logoAssetPath,
  });
}
