import 'package:equatable/equatable.dart';

/// Kariyer entity'si - bir oyuncunun tüm kariyer verisi.
class Career extends Equatable {
  final String id;
  final String playerName;
  final int playerAge;
  final String position;
  final String teamId;
  final String teamName;
  final int currentSeason;
  final int currentLevel;
  final int totalScore;
  final int totalGoals;
  final int matchesPlayed;
  final int levelsCompleted;
  final List<String> trophies;
  final DateTime createdAt;
  final DateTime lastPlayedAt;

  const Career({
    required this.id,
    required this.playerName,
    required this.playerAge,
    required this.position,
    required this.teamId,
    this.teamName = '',
    this.currentSeason = 1,
    this.currentLevel = 1,
    this.totalScore = 0,
    this.totalGoals = 0,
    this.matchesPlayed = 0,
    this.levelsCompleted = 0,
    this.trophies = const [],
    required this.createdAt,
    required this.lastPlayedAt,
  });

  Career copyWith({
    String? playerName,
    int? playerAge,
    String? position,
    String? teamId,
    String? teamName,
    int? currentSeason,
    int? currentLevel,
    int? totalScore,
    int? totalGoals,
    int? matchesPlayed,
    int? levelsCompleted,
    List<String>? trophies,
    DateTime? lastPlayedAt,
  }) {
    return Career(
      id: id,
      playerName: playerName ?? this.playerName,
      playerAge: playerAge ?? this.playerAge,
      position: position ?? this.position,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      currentSeason: currentSeason ?? this.currentSeason,
      currentLevel: currentLevel ?? this.currentLevel,
      totalScore: totalScore ?? this.totalScore,
      totalGoals: totalGoals ?? this.totalGoals,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      levelsCompleted: levelsCompleted ?? this.levelsCompleted,
      trophies: trophies ?? this.trophies,
      createdAt: createdAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerName': playerName,
        'playerAge': playerAge,
        'position': position,
        'teamId': teamId,
        'teamName': teamName,
        'currentSeason': currentSeason,
        'currentLevel': currentLevel,
        'totalScore': totalScore,
        'totalGoals': totalGoals,
        'matchesPlayed': matchesPlayed,
        'levelsCompleted': levelsCompleted,
        'trophies': trophies,
        'createdAt': createdAt.toIso8601String(),
        'lastPlayedAt': lastPlayedAt.toIso8601String(),
      };

  factory Career.fromJson(Map<String, dynamic> json) => Career(
        id: json['id'] as String,
        playerName: json['playerName'] as String,
        playerAge: json['playerAge'] as int,
        position: json['position'] as String,
        teamId: json['teamId'] as String,
        teamName: json['teamName'] as String? ?? '',
        currentSeason: json['currentSeason'] as int? ?? 1,
        currentLevel: json['currentLevel'] as int? ?? 1,
        totalScore: json['totalScore'] as int? ?? 0,
        totalGoals: json['totalGoals'] as int? ?? 0,
        matchesPlayed: json['matchesPlayed'] as int? ?? 0,
        levelsCompleted: json['levelsCompleted'] as int? ?? 0,
        trophies: (json['trophies'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastPlayedAt: DateTime.parse(json['lastPlayedAt'] as String),
      );

  @override
  List<Object?> get props => [id];
}
