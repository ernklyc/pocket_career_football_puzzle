import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Sabit level deposu.
/// Önceden üretilmiş 100 leveli assets/levels.json'dan okur.
/// Anlık yükleme — runtime üretim yok.
///
/// Level güncelleme akışı:
///   1. lib/game/level_configs.dart → parametreleri düzenle
///   2. dart run bin/generate_levels.dart → JSON üret
///   3. Uygulamayı build et → yeni leveller gömülü gelir
class LevelRepository {
  static const int totalLevels = 100;

  List<PuzzleLevel>? _cachedLevels;

  /// Levelleri assets/levels.json'dan yükle.
  Future<void> init() async {
    if (_cachedLevels != null) return;

    try {
      final stopwatch = Stopwatch()..start();
      final jsonString = await rootBundle.loadString('assets/levels.json');
      final list = jsonDecode(jsonString) as List;

      _cachedLevels = list
          .map((item) => PuzzleLevel.fromJson(item as Map<String, dynamic>))
          .toList();

      stopwatch.stop();
      AppLogger.info(
        '${_cachedLevels!.length} level yüklendi (${stopwatch.elapsedMilliseconds}ms)',
      );
    } catch (e) {
      AppLogger.error('Level yükleme hatası', error: e);
      _cachedLevels = [];
    }
  }

  /// Tek level yükle (1-indexed).
  PuzzleLevel? getLevel(int levelNumber) {
    if (_cachedLevels == null) return null;
    if (levelNumber < 1 || levelNumber > _cachedLevels!.length) return null;
    return _cachedLevels![levelNumber - 1];
  }

  /// Tüm levelleri al.
  List<PuzzleLevel> getAllLevels() => _cachedLevels ?? [];

  /// Toplam level sayısı.
  int get levelCount => _cachedLevels?.length ?? 0;
}
