import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/career.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Kariyer yönetim servisi — tek kariyer.
class CareerService {
  final LocalStorage _storage;
  static const _uuid = Uuid();

  CareerService(this._storage);

  /// Aktif kariyer.
  Career? get activeCareer {
    try {
      final json = _storage.careersJson;
      if (json != null) {
        final list = jsonDecode(json) as List<dynamic>;
        if (list.isNotEmpty) {
          return Career.fromJson(list.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      AppLogger.error('Kariyer yüklenirken hata', error: e);
    }
    return null;
  }

  /// Kariyer var mı kontrolü.
  bool get hasCareer => activeCareer != null;

  /// Yeni kariyer oluştur (varsa eskiyi siler).
  Future<Career> createCareer({
    required String playerName,
    required int playerAge,
    required String position,
    required String teamId,
    String teamName = '',
  }) async {
    final now = DateTime.now();
    final career = Career(
      id: _uuid.v4(),
      playerName: playerName,
      playerAge: playerAge,
      position: position,
      teamId: teamId,
      teamName: teamName,
      createdAt: now,
      lastPlayedAt: now,
    );

    await _saveCareer(career);
    AppLogger.info('Kariyer oluşturuldu: ${career.playerName} - $teamId');
    return career;
  }

  /// Kariyeri güncelle.
  Future<void> updateCareer(Career updatedCareer) async {
    await _saveCareer(updatedCareer);
  }

  /// Kariyeri sıfırla — tüm veriyi siler.
  Future<void> resetCareer() async {
    await _storage.clearAll();
    AppLogger.info('Kariyer sıfırlandı — tüm veriler silindi');
  }

  /// Level tamamlandığında kariyeri güncelle.
  Future<Career?> onLevelCompleted({
    required int score,
    required bool isGoal,
  }) async {
    final career = activeCareer;
    if (career == null) return null;

    final updated = career.copyWith(
      totalScore: career.totalScore + score,
      totalGoals: career.totalGoals + (isGoal ? 1 : 0),
      matchesPlayed: career.matchesPlayed + 1,
      levelsCompleted: career.levelsCompleted + 1,
      currentLevel: career.currentLevel + 1,
      lastPlayedAt: DateTime.now(),
    );

    // Sezon kontrolü
    final finalCareer = _checkSeasonAdvance(updated);
    await updateCareer(finalCareer);
    return finalCareer;
  }

  Career _checkSeasonAdvance(Career career) {
    if (career.currentLevel > AppConfig.levelsPerSeason) {
      return career.copyWith(
        currentSeason: career.currentSeason + 1,
        currentLevel: 1,
        trophies: [...career.trophies, 'season_${career.currentSeason}'],
      );
    }
    return career;
  }

  Future<void> _saveCareer(Career career) async {
    final jsonList = [career.toJson()];
    await _storage.setCareersJson(jsonEncode(jsonList));
    await _storage.setActiveCareerIndex(0);
  }
}
