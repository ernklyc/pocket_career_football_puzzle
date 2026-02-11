/// Blok koleksiyonu — açılan blok şekilleri sistemi.
/// Her 10 levelde yeni blok tipleri açılır.
class BlockShape {
  final String id;
  final String name;
  final String nameTr;
  final int width;
  final int height;
  final int unlockAtLevel; // Bu level'dan itibaren kullanılır
  final String emoji;

  const BlockShape({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.width,
    required this.height,
    required this.unlockAtLevel,
    required this.emoji,
  });

  String get sizeLabel => '${width}x$height';

  /// Bu şekil belirtilen level'da açık mı?
  bool isUnlockedAt(int currentLevel) => currentLevel >= unlockAtLevel;
}

/// Tüm blok şekilleri.
class BlockCollection {
  BlockCollection._();

  static const List<BlockShape> allShapes = [
    // Bölge 1 (Level 1+) — Temel bloklar
    BlockShape(
      id: 'h1x2',
      name: 'Horizontal Small',
      nameTr: 'Yatay Küçük',
      width: 2,
      height: 1,
      unlockAtLevel: 1,
      emoji: '🟧',
    ),
    BlockShape(
      id: 'v2x1',
      name: 'Vertical Small',
      nameTr: 'Dikey Küçük',
      width: 1,
      height: 2,
      unlockAtLevel: 1,
      emoji: '🟪',
    ),

    // Bölge 2 (Level 11+) — Küçük kare
    BlockShape(
      id: 's1x1',
      name: 'Small Square',
      nameTr: 'Küçük Kare',
      width: 1,
      height: 1,
      unlockAtLevel: 11,
      emoji: '🟦',
    ),

    // Bölge 3 (Level 21+) — Uzun bloklar
    BlockShape(
      id: 'h1x3',
      name: 'Horizontal Long',
      nameTr: 'Yatay Uzun',
      width: 3,
      height: 1,
      unlockAtLevel: 21,
      emoji: '🟠',
    ),
    BlockShape(
      id: 'v3x1',
      name: 'Vertical Long',
      nameTr: 'Dikey Uzun',
      width: 1,
      height: 3,
      unlockAtLevel: 21,
      emoji: '🟣',
    ),

    // Bölge 5 (Level 41+) — Büyük kare
    BlockShape(
      id: 'b2x2',
      name: 'Big Square',
      nameTr: 'Büyük Kare',
      width: 2,
      height: 2,
      unlockAtLevel: 41,
      emoji: '🟥',
    ),
  ];

  /// Belirli level'da açık olan şekiller.
  static List<BlockShape> unlockedAt(int level) {
    return allShapes.where((s) => s.isUnlockedAt(level)).toList();
  }

  /// Belirli level'da kilitli olan şekiller.
  static List<BlockShape> lockedAt(int level) {
    return allShapes.where((s) => !s.isUnlockedAt(level)).toList();
  }

  /// Bir sonraki açılacak blok grubu ve açılacağı level.
  static ({int level, List<BlockShape> shapes})? nextUnlock(int currentLevel) {
    final locked = lockedAt(currentLevel);
    if (locked.isEmpty) return null;

    final nextLevel = locked.map((s) => s.unlockAtLevel).reduce(
        (a, b) => a < b ? a : b);
    final shapes = locked.where((s) => s.unlockAtLevel == nextLevel).toList();

    return (level: nextLevel, shapes: shapes);
  }
}
