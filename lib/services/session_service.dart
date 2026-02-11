import 'package:pocket_career_football_puzzle/domain/entities/session_result.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Oyun oturumu servisi. Tek oturumun yaşam döngüsünü yönetir.
class SessionService {
  DateTime? _sessionStart;
  PuzzleLevel? _currentLevel;

  /// Oturumu başlat.
  void startSession(PuzzleLevel level) {
    _sessionStart = DateTime.now();
    _currentLevel = level;
    AppLogger.info('Oturum başladı: S${level.season}-L${level.levelNumber}');
  }

  /// Oturumu bitir ve sonuç oluştur.
  SessionResult endSession({
    required int score,
    required int movesUsed,
    required bool isCompleted,
    required bool isNewRecord,
  }) {
    final duration = _sessionStart != null
        ? DateTime.now().difference(_sessionStart!)
        : Duration.zero;

    int coinsEarned = 0;
    if (isCompleted) {
      coinsEarned = EconomyConfig.levelCompleteBaseReward;

      // Mükemmel çözüm bonusu
      if (_currentLevel != null && movesUsed <= _currentLevel!.optimalMoves) {
        coinsEarned += EconomyConfig.perfectLevelBonus;
      }
    }

    final result = SessionResult(
      levelNumber: _currentLevel?.levelNumber ?? 0,
      season: _currentLevel?.season ?? 1,
      score: score,
      movesUsed: movesUsed,
      movesMax: _currentLevel?.maxMoves ?? 0,
      optimalMoves: _currentLevel?.optimalMoves ?? 0,
      coinsEarned: coinsEarned,
      isNewRecord: isNewRecord,
      isCompleted: isCompleted,
      duration: duration,
    );

    AppLogger.info(
        'Oturum bitti: Skor=$score, Tamamlandı=$isCompleted, Coin=$coinsEarned');

    _sessionStart = null;
    _currentLevel = null;

    return result;
  }

  /// Puan hesapla.
  static int calculateScore({
    required int levelNumber,
    required int movesUsed,
    required int maxMoves,
  }) {
    final difficulty = 1.0 +
        (levelNumber - 1) * (EconomyConfig.levelDifficultyMultiplier - 1);
    final basePoints = (EconomyConfig.baseScore * difficulty).round();
    final remainingMoves = maxMoves - movesUsed;
    final bonus =
        (remainingMoves * EconomyConfig.remainingMoveBonusPerMove).round();

    return basePoints + bonus;
  }
}
