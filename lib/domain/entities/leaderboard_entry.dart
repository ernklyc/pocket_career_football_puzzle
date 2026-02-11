import 'package:equatable/equatable.dart';

/// Skor tablosu girdisi.
class LeaderboardEntry extends Equatable {
  final String odId;
  final String playerName;
  final String teamId;
  final String teamName;
  final String teamLogoEmoji;
  final int score;
  final int rank;
  final DateTime updatedAt;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.odId,
    required this.playerName,
    required this.teamId,
    this.teamName = '',
    this.teamLogoEmoji = '⚽',
    required this.score,
    required this.rank,
    required this.updatedAt,
    this.isCurrentUser = false,
  });

  Map<String, dynamic> toJson() => {
        'odId': odId,
        'playerName': playerName,
        'teamId': teamId,
        'teamName': teamName,
        'teamLogoEmoji': teamLogoEmoji,
        'score': score,
        'rank': rank,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json,
          {bool isCurrentUser = false}) =>
      LeaderboardEntry(
        odId: json['odId'] as String? ?? '',
        playerName: json['playerName'] as String? ?? 'Unknown',
        teamId: json['teamId'] as String? ?? '',
        teamName: json['teamName'] as String? ?? '',
        teamLogoEmoji: json['teamLogoEmoji'] as String? ?? '⚽',
        score: json['score'] as int? ?? 0,
        rank: json['rank'] as int? ?? 0,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        isCurrentUser: isCurrentUser,
      );

  @override
  List<Object?> get props => [odId, score];
}
