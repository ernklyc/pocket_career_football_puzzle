import 'dart:convert';
import 'dart:math';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/leaderboard_entry.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Skor tablosu servisi (local + remote adapter).
class LeaderboardService {
  final LocalStorage _storage;
  static final _rng = Random(42);

  LeaderboardService(this._storage);

  /// Local leaderboard'u yükle.
  List<LeaderboardEntry> loadLocalLeaderboard() {
    try {
      final json = _storage.localLeaderboardJson;
      if (json != null) {
        final list = jsonDecode(json) as List<dynamic>;
        return list
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
      }
    } catch (e) {
      AppLogger.error('Leaderboard yüklenirken hata', error: e);
    }
    return [];
  }

  /// Local leaderboard'a skor ekle.
  Future<void> submitLocalScore({
    required String odId,
    required String playerName,
    required String teamId,
    String teamName = '',
    String teamLogoEmoji = '⚽',
    required int score,
  }) async {
    final entries = loadLocalLeaderboard();

    final existingIdx = entries.indexWhere((e) => e.odId == odId);
    if (existingIdx != -1) {
      // Sadece daha yüksek skoru güncelle
      if (entries[existingIdx].score >= score) return;
      entries.removeAt(existingIdx);
    }

    entries.add(LeaderboardEntry(
      odId: odId,
      playerName: playerName,
      teamId: teamId,
      teamName: teamName,
      teamLogoEmoji: teamLogoEmoji,
      score: score,
      rank: 0,
      updatedAt: DateTime.now(),
    ));

    // Sırala ve rank ata
    entries.sort((a, b) => b.score.compareTo(a.score));
    final ranked = entries.asMap().entries.map((e) {
      return LeaderboardEntry(
        odId: e.value.odId,
        playerName: e.value.playerName,
        teamId: e.value.teamId,
        teamName: e.value.teamName,
        teamLogoEmoji: e.value.teamLogoEmoji,
        score: e.value.score,
        rank: e.key + 1,
        updatedAt: e.value.updatedAt,
        isCurrentUser: e.value.odId == odId,
      );
    }).toList();

    // Max 50 girdi
    final trimmed = ranked.take(50).toList();
    await _storage.setLocalLeaderboardJson(
        jsonEncode(trimmed.map((e) => e.toJson()).toList()));

    AppLogger.info('Local leaderboard güncellendi: $playerName - $score');
  }

  /// Simüle rakipler oluştur (lokal leaderboard'u doldur).
  Future<void> ensureSimulatedOpponents() async {
    final entries = loadLocalLeaderboard();
    // Eğer zaten yeterli rakip varsa oluşturma
    final simCount = entries.where((e) => !e.isCurrentUser).length;
    if (simCount >= 8) return;

    final simData = [
      ('Ayhan', 'Aslanlar', '🦁', 'galatasaray'),
      ('Messi_Fan', 'Barça FC', '🔵🔴', 'barcelona'),
      ('CR7_King', 'Real Stars', '👑', 'real_madrid'),
      ('Kartal23', 'Kartallar', '🦅', 'besiktas'),
      ('Arda_G', 'Sarı Yıldız', '⭐', 'fenerbahce'),
      ('Fırtına', 'Bordo Mavi', '🌊', 'trabzonspor'),
      ('Hakan_07', 'Bayern FK', '🔴', 'bayern'),
      ('Kerem_11', 'City Stars', '🏙️', 'mancity'),
      ('Barış', 'Les Parisiens', '🗼', 'psg'),
      ('Zeki', 'Red Army', '🔴', 'liverpool'),
    ];

    for (int i = simCount; i < 8; i++) {
      final data = simData[i % simData.length];
      final score = _rng.nextInt(180) + 20;

      entries.add(LeaderboardEntry(
        odId: 'sim_$i',
        playerName: data.$1,
        teamId: data.$4,
        teamName: data.$2,
        teamLogoEmoji: data.$3,
        score: score,
        rank: 0,
        updatedAt: DateTime.now(),
      ));
    }

    entries.sort((a, b) => b.score.compareTo(a.score));
    final ranked = entries.asMap().entries.map((e) {
      return LeaderboardEntry(
        odId: e.value.odId,
        playerName: e.value.playerName,
        teamId: e.value.teamId,
        teamName: e.value.teamName,
        teamLogoEmoji: e.value.teamLogoEmoji,
        score: e.value.score,
        rank: e.key + 1,
        updatedAt: e.value.updatedAt,
        isCurrentUser: e.value.isCurrentUser,
      );
    }).toList();

    await _storage.setLocalLeaderboardJson(
        jsonEncode(ranked.map((e) => e.toJson()).toList()));
  }

  /// Haftalık kupa kontrolü: oyuncunun haftalık sıralamasına göre kupa al.
  String? checkWeeklyTrophyEligibility(String playerId) {
    final entries = loadLocalLeaderboard();
    final playerEntry = entries.where((e) => e.odId == playerId || e.isCurrentUser).firstOrNull;
    if (playerEntry == null) return null;

    final rank = entries.indexOf(playerEntry) + 1;
    if (rank == 1) return 'weekly_gold';
    if (rank == 2) return 'weekly_silver';
    if (rank == 3) return 'weekly_bronze';
    return null;
  }
}
