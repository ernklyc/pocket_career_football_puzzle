import 'dart:convert';
import 'package:pocket_career_football_puzzle/core/config/progression_schema.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// İlerleme durumu.
class ProgressData {
  final Map<String, LevelProgress> levels;
  final int currentLevel; // 1-100 arası en yüksek açık level

  const ProgressData({this.levels = const {}, this.currentLevel = 1});

  ProgressData copyWith({
    Map<String, LevelProgress>? levels,
    int? currentLevel,
  }) {
    return ProgressData(
      levels: levels ?? this.levels,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  /// Toplam puan (tüm levellerin maç puanları toplamı).
  int get totalPoints {
    int sum = 0;
    for (final lp in levels.values) {
      sum += lp.matchPoints;
    }
    return sum;
  }

  Map<String, dynamic> toJson() => {
    'levels': levels.map((k, v) => MapEntry(k, v.toJson())),
    'currentLevel': currentLevel,
  };

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final levelsMap = json['levels'] as Map<String, dynamic>? ?? {};
    return ProgressData(
      levels: levelsMap.map(
        (k, v) =>
            MapEntry(k, LevelProgress.fromJson(v as Map<String, dynamic>)),
      ),
      currentLevel: json['currentLevel'] as int? ?? 1,
    );
  }
}

/// Tek bir leveldeki ilerleme.
class LevelProgress {
  final bool completed;
  final int bestScore;
  final int bestMoves;

  /// Futbol puanlama: 3 = Galibiyet, 1 = Beraberlik, 0 = Mağlubiyet.
  final int matchPoints;

  const LevelProgress({
    this.completed = false,
    this.bestScore = 0,
    this.bestMoves = 0,
    this.matchPoints = 0,
  });

  /// Maç sonucu.
  MatchResult get matchResult {
    if (matchPoints >= 3) return MatchResult.win;
    if (matchPoints >= 1) return MatchResult.draw;
    return MatchResult.loss;
  }

  Map<String, dynamic> toJson() => {
    'completed': completed,
    'bestScore': bestScore,
    'bestMoves': bestMoves,
    'matchPoints': matchPoints,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    completed: json['completed'] as bool? ?? false,
    bestScore: json['bestScore'] as int? ?? 0,
    bestMoves: json['bestMoves'] as int? ?? 0,
    matchPoints: json['matchPoints'] as int? ?? json['stars'] as int? ?? 0,
  );
}

/// İlerleme servisi — kariyer bazlı.
class ProgressService {
  final LocalStorage _storage;
  String? _activeCareerId;

  ProgressService(this._storage);

  /// Aktif kariyer ID'sini ayarla.
  void setActiveCareerId(String? careerId) {
    _activeCareerId = careerId;
  }

  ProgressData loadProgress() {
    try {
      // Kariyer bazlı
      if (_activeCareerId != null) {
        final json = _storage.getCareerProgressJson(_activeCareerId!);
        if (json != null) {
          return ProgressData.fromJson(jsonDecode(json));
        }
      }
      // Fallback: global ilerleme (eski versiyon desteği)
      final json = _storage.progressJson;
      if (json != null) {
        return ProgressData.fromJson(jsonDecode(json));
      }
    } catch (e) {
      AppLogger.error('İlerleme yüklenirken hata', error: e);
    }
    return const ProgressData();
  }

  Future<void> saveProgress(ProgressData progress) async {
    if (_activeCareerId != null) {
      await _storage.setCareerProgressJson(
        _activeCareerId!,
        jsonEncode(progress.toJson()),
      );
    } else {
      await _storage.setProgressJson(jsonEncode(progress.toJson()));
    }
  }

  /// Level tamamla — futbol puanlama sistemi.
  Future<ProgressData> completeLevel({
    required int level,
    required int score,
    required int movesUsed,
    required int optimalMoves,
    required int maxMoves,
  }) async {
    final progress = loadProgress();
    final key = '$level';

    final existing = progress.levels[key];
    final points = calculateMatchPoints(
      movesUsed: movesUsed,
      optimalMoves: optimalMoves,
      maxMoves: maxMoves,
    );

    final levelProgress = LevelProgress(
      completed: true,
      bestScore: (existing != null && existing.bestScore > score)
          ? existing.bestScore
          : score,
      bestMoves:
          (existing != null &&
              existing.bestMoves > 0 &&
              existing.bestMoves < movesUsed)
          ? existing.bestMoves
          : movesUsed,
      matchPoints: (existing != null && existing.matchPoints > points)
          ? existing.matchPoints
          : points,
    );

    final updatedLevels = Map<String, LevelProgress>.from(progress.levels);
    updatedLevels[key] = levelProgress;

    // Sonraki level'a ilerle — schema'dan max
    final nextLevel = (level + 1).clamp(1, ProgressionSchema.levelCount);

    final updated = progress.copyWith(
      levels: updatedLevels,
      currentLevel: nextLevel > progress.currentLevel
          ? nextLevel
          : progress.currentLevel,
    );

    await saveProgress(updated);
    AppLogger.info('Level $level tamamlandı: Skor=$score, Puan=$points');
    return updated;
  }

  /// Level açık mı?
  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    final progress = loadProgress();

    if (level <= progress.currentLevel) return true;

    // Önceki level tamamlanmış mı?
    final prevKey = '${level - 1}';
    return progress.levels[prevKey]?.completed ?? false;
  }

  /// Futbol puanlama hesaplama (statik — dışarıdan da çağrılabilir).
  ///
  /// 3 puan (Galibiyet): hamle <= optimal
  /// 1 puan (Beraberlik): hamle <= optimal + ceil((max - optimal) * 0.5)
  /// 0 puan (Mağlubiyet): hamle > beraberlik eşiği
  static int calculateMatchPoints({
    required int movesUsed,
    required int optimalMoves,
    required int maxMoves,
  }) {
    final winThreshold = optimalMoves;
    final drawThreshold =
        optimalMoves + ((maxMoves - optimalMoves) * 0.5).ceil();

    if (movesUsed <= winThreshold) return 3; // Galibiyet
    if (movesUsed <= drawThreshold) return 1; // Beraberlik
    return 0; // Mağlubiyet
  }

  /// Maç sonucu etiketi.
  static MatchResult matchResultFromPoints(int points) {
    if (points >= 3) return MatchResult.win;
    if (points >= 1) return MatchResult.draw;
    return MatchResult.loss;
  }

  /// DEBUG: İstenen levele atla. Önceki tüm levelleri tamamlanmış işaretle.
  Future<void> jumpToLevel(int targetLevel) async {
    final progress = loadProgress();
    final updatedLevels = Map<String, LevelProgress>.from(progress.levels);

    // Önceki levelleri çözülmüş say
    for (int i = 1; i < targetLevel; i++) {
      final key = '$i';
      if (updatedLevels[key] == null || !updatedLevels[key]!.completed) {
        updatedLevels[key] = const LevelProgress(
          completed: true,
          bestScore: 100,
          bestMoves: 3,
          matchPoints: 3,
        );
      }
    }

    final updated = progress.copyWith(
      levels: updatedLevels,
      currentLevel: targetLevel,
    );
    await saveProgress(updated);
    AppLogger.info('DEBUG: Level $targetLevel\'e atlandı');
  }
}
