// ============================================================
// PROGRESSION SCHEMA — Tek Kaynak
// ============================================================
// LevelConfig'ten türetilen salt okunur meta-veri.
// Leveller, blok unlock, bölge aralıkları hep buradan.
// ============================================================

import 'package:pocket_career_football_puzzle/game/level_configs.dart';

class ProgressionSchema {
  ProgressionSchema._();

  static const int levelsPerChapter = 10;

  /// Toplam level sayısı — LevelConfig'ten.
  static int get levelCount => allLevelConfigs.length;

  /// Bölge (chapter) sayısı.
  static int get chapterCount =>
      (levelCount / levelsPerChapter).ceil().clamp(1, 999);

  /// Belirli bölge için level aralığı (1-indexed, dahil).
  /// chapterIndex 0-based (0 = ilk bölge).
  static (int start, int end) chapterRange(int chapterIndex) {
    final start = chapterIndex * levelsPerChapter + 1;
    final end = (start + levelsPerChapter - 1).clamp(1, levelCount);
    return (start, end);
  }

  /// LevelConfig.shapes (height, width) formatında.
  /// Dönüş: (width, height).
  static int blockFirstAppearance(int width, int height) {
    for (final config in allLevelConfigs) {
      for (final sh in config.shapes) {
        // config: (height, width)
        if (sh.$2 == width && sh.$1 == height) return config.level;
      }
    }
    return levelCount + 1; // hiç yoksa en sonra
  }

  /// LevelConfig'teki tüm unique (width, height) çiftleri.
  static Set<(int, int)> get allBlockShapeSizes {
    final set = <(int, int)>{};
    for (final config in allLevelConfigs) {
      for (final sh in config.shapes) {
        set.add((sh.$2, sh.$1)); // (width, height)
      }
    }
    return set;
  }

  /// effectiveLevel'a kadar oyunda görünen (width, height) çiftleri.
  static Set<(int, int)> shapesInLevelsUpTo(int effectiveLevel) {
    final set = <(int, int)>{};
    for (final config in allLevelConfigs) {
      if (config.level <= effectiveLevel) {
        for (final sh in config.shapes) {
          set.add((sh.$2, sh.$1));
        }
      }
    }
    return set;
  }
}
