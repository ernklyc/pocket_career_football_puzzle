import 'package:equatable/equatable.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';

/// Oyun oturumu sonucu.
class SessionResult extends Equatable {
  final int levelNumber;
  final int season;
  final int score;
  final int movesUsed;
  final int movesMax;
  final int optimalMoves;
  final int coinsEarned;
  final bool isNewRecord;
  final bool isCompleted;
  final Duration duration;

  const SessionResult({
    required this.levelNumber,
    required this.season,
    required this.score,
    required this.movesUsed,
    required this.movesMax,
    required this.optimalMoves,
    required this.coinsEarned,
    required this.isNewRecord,
    required this.isCompleted,
    required this.duration,
  });

  int get movesRemaining => movesMax - movesUsed;
  double get efficiency =>
      movesMax > 0 ? (movesMax - movesUsed) / movesMax : 0;

  /// Futbol maç puanı (3, 1, 0).
  int get matchPoints {
    if (!isCompleted || optimalMoves <= 0) return 0;
    final winThreshold = optimalMoves;
    final drawThreshold =
        optimalMoves + ((movesMax - optimalMoves) * 0.5).ceil();
    if (movesUsed <= winThreshold) return 3;
    if (movesUsed <= drawThreshold) return 1;
    return 0;
  }

  /// Maç sonucu.
  MatchResult get matchResult {
    if (!isCompleted) return MatchResult.loss;
    final pts = matchPoints;
    if (pts >= 3) return MatchResult.win;
    if (pts >= 1) return MatchResult.draw;
    return MatchResult.loss;
  }

  @override
  List<Object?> get props => [levelNumber, season, score, isCompleted];
}
