import 'dart:convert';

/// Oyuncunun aktif kozmetik ayarları.
class ActiveCosmetics {
  /// Aktif top skin'i (null = default)
  final String? activeBallSkin;

  /// Aktif blok teması (null = default)
  final String? activeBlockTheme;

  /// Aktif profil rozeti (null = default)
  final String? activeProfileBadge;

  const ActiveCosmetics({
    this.activeBallSkin,
    this.activeBlockTheme,
    this.activeProfileBadge,
  });

  ActiveCosmetics copyWith({
    String? activeBallSkin,
    String? activeBlockTheme,
    String? activeProfileBadge,
    bool clearBallSkin = false,
    bool clearBlockTheme = false,
    bool clearProfileBadge = false,
  }) {
    return ActiveCosmetics(
      activeBallSkin: clearBallSkin ? null : (activeBallSkin ?? this.activeBallSkin),
      activeBlockTheme: clearBlockTheme ? null : (activeBlockTheme ?? this.activeBlockTheme),
      activeProfileBadge: clearProfileBadge ? null : (activeProfileBadge ?? this.activeProfileBadge),
    );
  }

  Map<String, dynamic> toJson() => {
        if (activeBallSkin != null) 'activeBallSkin': activeBallSkin,
        if (activeBlockTheme != null) 'activeBlockTheme': activeBlockTheme,
        if (activeProfileBadge != null) 'activeProfileBadge': activeProfileBadge,
      };

  factory ActiveCosmetics.fromJson(Map<String, dynamic> json) =>
      ActiveCosmetics(
        activeBallSkin: json['activeBallSkin'] as String?,
        activeBlockTheme: json['activeBlockTheme'] as String?,
        activeProfileBadge: json['activeProfileBadge'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory ActiveCosmetics.fromJsonString(String jsonStr) {
    try {
      return ActiveCosmetics.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return const ActiveCosmetics();
    }
  }
}

/// Kozmetik tanımları — mağazadan satın alınabilir.
class CosmeticDefinitions {
  CosmeticDefinitions._();

  // Top skin'leri
  static const Map<String, BallSkinDef> ballSkins = {
    'gold_ball': BallSkinDef(id: 'gold_ball', name: 'Altın Top', color: 0xFFFFD700, description: 'Parlak altın top'),
    'fire_ball': BallSkinDef(id: 'fire_ball', name: 'Ateş Top', color: 0xFFFF5722, description: 'Ateşli kırmızı top'),
    'ice_ball': BallSkinDef(id: 'ice_ball', name: 'Buz Top', color: 0xFF00BCD4, description: 'Buz mavisi top'),
    'neon_ball': BallSkinDef(id: 'neon_ball', name: 'Neon Top', color: 0xFF76FF03, description: 'Parlak neon yeşil top'),
  };

  // Blok temaları
  static const Map<String, BlockThemeDef> blockThemes = {
    'wood_theme': BlockThemeDef(id: 'wood_theme', name: 'Ahşap', primaryColor: 0xFF8D6E63, secondaryColor: 0xFFA1887F, description: 'Ahşap blok teması'),
    'metal_theme': BlockThemeDef(id: 'metal_theme', name: 'Metal', primaryColor: 0xFF78909C, secondaryColor: 0xFF90A4AE, description: 'Metalik blok teması'),
    'candy_theme': BlockThemeDef(id: 'candy_theme', name: 'Şeker', primaryColor: 0xFFE91E63, secondaryColor: 0xFFF06292, description: 'Renkli şeker teması'),
  };

  // Profil rozetleri
  static const Map<String, BadgeDef> profileBadges = {
    'badge_1': BadgeDef(id: 'badge_1', name: 'Yıldız', emoji: '⭐', description: 'Yıldız rozeti'),
    'badge_champion': BadgeDef(id: 'badge_champion', name: 'Şampiyon', emoji: '🏆', description: 'Şampiyon rozeti'),
    'badge_fire': BadgeDef(id: 'badge_fire', name: 'Ateş', emoji: '🔥', description: 'Ateşli rozet'),
  };
}

class BallSkinDef {
  final String id;
  final String name;
  final int color;
  final String description;
  const BallSkinDef({required this.id, required this.name, required this.color, required this.description});
}

class BlockThemeDef {
  final String id;
  final String name;
  final int primaryColor;
  final int secondaryColor;
  final String description;
  const BlockThemeDef({required this.id, required this.name, required this.primaryColor, required this.secondaryColor, required this.description});
}

class BadgeDef {
  final String id;
  final String name;
  final String emoji;
  final String description;
  const BadgeDef({required this.id, required this.name, required this.emoji, required this.description});
}
