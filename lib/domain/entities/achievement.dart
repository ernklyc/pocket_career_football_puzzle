// Başarım sistemi — Bölge geçişleri, blok açılma ve puan başarımları.

enum AchievementCategory { chapter, blockUnlock, points }

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementCategory category;

  /// Bu başarımı kontrol etmek için gerekli koşul fonksiyonu.
  final bool Function(AchievementContext ctx) checkUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.category,
    required this.checkUnlocked,
  });
}

/// Başarım kontrolü için gerekli veriler.
class AchievementContext {
  final int currentLevel;
  final int totalPoints;
  final int completedLevelCount;
  final Map<int, int> levelMatchPoints; // levelNum -> matchPoints

  const AchievementContext({
    required this.currentLevel,
    required this.totalPoints,
    required this.completedLevelCount,
    required this.levelMatchPoints,
  });

  /// Belirli bölgedeki tüm leveller tamamlanmış mı?
  bool isChapterComplete(int chapterStart, int chapterEnd) {
    for (int i = chapterStart; i <= chapterEnd; i++) {
      if (!levelMatchPoints.containsKey(i)) return false;
    }
    return true;
  }

  /// Belirli bölgedeki tüm leveller galibiyet (3 puan) mı?
  bool isChapterPerfect(int chapterStart, int chapterEnd) {
    for (int i = chapterStart; i <= chapterEnd; i++) {
      if ((levelMatchPoints[i] ?? 0) < 3) return false;
    }
    return true;
  }
}

/// Tüm başarımlar.
class Achievements {
  Achievements._();

  static final List<Achievement> all = [
    // ═══════════════════════════════════════════
    // BÖLGE TAMAMLAMA BAŞARIMLARI (10 adet)
    // ═══════════════════════════════════════════
    Achievement(
      id: 'chapter_1',
      title: 'Bölge 1 Tamamlandı',
      description: 'Tüm 1-10 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(1, 10),
    ),
    Achievement(
      id: 'chapter_2',
      title: 'Bölge 2 Tamamlandı',
      description: 'Tüm 11-20 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(11, 20),
    ),
    Achievement(
      id: 'chapter_3',
      title: 'Bölge 3 Tamamlandı',
      description: 'Tüm 21-30 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(21, 30),
    ),
    Achievement(
      id: 'chapter_4',
      title: 'Bölge 4 Tamamlandı',
      description: 'Tüm 31-40 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(31, 40),
    ),
    Achievement(
      id: 'chapter_5',
      title: 'Bölge 5 Tamamlandı',
      description: 'Tüm 41-50 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(41, 50),
    ),
    Achievement(
      id: 'chapter_6',
      title: 'Bölge 6 Tamamlandı',
      description: 'Tüm 51-60 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(51, 60),
    ),
    Achievement(
      id: 'chapter_7',
      title: 'Bölge 7 Tamamlandı',
      description: 'Tüm 61-70 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(61, 70),
    ),
    Achievement(
      id: 'chapter_8',
      title: 'Bölge 8 Tamamlandı',
      description: 'Tüm 71-80 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(71, 80),
    ),
    Achievement(
      id: 'chapter_9',
      title: 'Bölge 9 Tamamlandı',
      description: 'Tüm 81-90 levelleri tamamla',
      emoji: '🏟️',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(81, 90),
    ),
    Achievement(
      id: 'chapter_10',
      title: 'Bölge 10 Tamamlandı',
      description: 'Tüm 91-100 levelleri tamamla',
      emoji: '🏆',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterComplete(91, 100),
    ),

    // ═══════════════════════════════════════════
    // BLOK AÇILMA BAŞARIMLARI
    // ═══════════════════════════════════════════
    Achievement(
      id: 'unlock_small',
      title: 'Küçük Kare Açıldı',
      description: 'Level 11\'e ulaş — 1x1 blok',
      emoji: '🟦',
      category: AchievementCategory.blockUnlock,
      checkUnlocked: (ctx) => ctx.currentLevel >= 11,
    ),
    Achievement(
      id: 'unlock_long',
      title: 'Uzun Bloklar Açıldı',
      description: 'Level 21\'e ulaş — 1x3 ve 3x1 bloklar',
      emoji: '🟠',
      category: AchievementCategory.blockUnlock,
      checkUnlocked: (ctx) => ctx.currentLevel >= 21,
    ),
    Achievement(
      id: 'unlock_big',
      title: 'Büyük Kare Açıldı',
      description: 'Level 41\'e ulaş — 2x2 blok',
      emoji: '🟥',
      category: AchievementCategory.blockUnlock,
      checkUnlocked: (ctx) => ctx.currentLevel >= 41,
    ),
    Achievement(
      id: 'unlock_all_blocks',
      title: 'Tam Koleksiyon',
      description: 'Tüm blok tiplerini aç',
      emoji: '🎨',
      category: AchievementCategory.blockUnlock,
      checkUnlocked: (ctx) => ctx.currentLevel >= 41,
    ),

    // ═══════════════════════════════════════════
    // PUAN BAŞARIMLARI
    // ═══════════════════════════════════════════
    Achievement(
      id: 'points_30',
      title: 'İlk Sezon',
      description: '30 toplam puana ulaş',
      emoji: '⭐',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 30,
    ),
    Achievement(
      id: 'points_60',
      title: 'Yükselen Yıldız',
      description: '60 toplam puana ulaş',
      emoji: '🌟',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 60,
    ),
    Achievement(
      id: 'points_100',
      title: 'Yüz Puan',
      description: '100 toplam puana ulaş',
      emoji: '💯',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 100,
    ),
    Achievement(
      id: 'points_150',
      title: 'Şampiyon Adayı',
      description: '150 toplam puana ulaş',
      emoji: '🏅',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 150,
    ),
    Achievement(
      id: 'points_200',
      title: 'Süper Lig',
      description: '200 toplam puana ulaş',
      emoji: '🥇',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 200,
    ),
    Achievement(
      id: 'points_250',
      title: 'Efsane',
      description: '250 toplam puana ulaş',
      emoji: '👑',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 250,
    ),
    Achievement(
      id: 'points_300',
      title: 'Kusursuz Sezon',
      description: '300 toplam puana ulaş (maksimum)',
      emoji: '🏆',
      category: AchievementCategory.points,
      checkUnlocked: (ctx) => ctx.totalPoints >= 300,
    ),

    // ═══════════════════════════════════════════
    // MÜKEMMEL BÖLGE (tüm galibiyetler)
    // ═══════════════════════════════════════════
    Achievement(
      id: 'perfect_1',
      title: 'Bölge 1 Mükemmel',
      description: 'Bölge 1\'de tüm levelleri galibiyet ile bitir',
      emoji: '🌟',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterPerfect(1, 10),
    ),
    Achievement(
      id: 'perfect_5',
      title: 'İlk Yarı Mükemmel',
      description: 'İlk 50 leveli galibiyet ile bitir',
      emoji: '💫',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterPerfect(1, 50),
    ),
    Achievement(
      id: 'perfect_all',
      title: 'Altın Top',
      description: 'Tüm 100 leveli galibiyet ile bitir',
      emoji: '⚽',
      category: AchievementCategory.chapter,
      checkUnlocked: (ctx) => ctx.isChapterPerfect(1, 100),
    ),
  ];

  /// Belirli context'te açık olan başarımlar.
  static List<Achievement> unlockedAchievements(AchievementContext ctx) {
    return all.where((a) => a.checkUnlocked(ctx)).toList();
  }

  /// Kilitli başarımlar.
  static List<Achievement> lockedAchievements(AchievementContext ctx) {
    return all.where((a) => !a.checkUnlocked(ctx)).toList();
  }
}
