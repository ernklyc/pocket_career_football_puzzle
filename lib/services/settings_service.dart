import 'dart:convert';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/domain/entities/game_settings.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Ayarlar servisi.
class SettingsService {
  final LocalStorage _storage;

  SettingsService(this._storage);

  GameSettings loadSettings() {
    try {
      final json = _storage.settingsJson;
      if (json != null) {
        return GameSettings.fromJson(jsonDecode(json));
      }
    } catch (e) {
      AppLogger.error('Ayarlar yüklenirken hata', error: e);
    }
    return const GameSettings();
  }

  Future<void> saveSettings(GameSettings settings) async {
    await _storage.setSettingsJson(jsonEncode(settings.toJson()));
    AppLogger.info('Ayarlar kaydedildi: ${settings.language}');
  }

  Future<void> updateLanguage(String language) async {
    final current = loadSettings();
    await saveSettings(current.copyWith(language: language));
  }

  Future<void> toggleMusic(bool enabled) async {
    final current = loadSettings();
    await saveSettings(current.copyWith(musicEnabled: enabled));
  }

  Future<void> toggleSound(bool enabled) async {
    final current = loadSettings();
    await saveSettings(current.copyWith(soundEnabled: enabled));
  }

  Future<void> toggleHaptics(bool enabled) async {
    final current = loadSettings();
    await saveSettings(current.copyWith(hapticsEnabled: enabled));
  }

  Future<void> toggleNotifications(bool enabled) async {
    final current = loadSettings();
    await saveSettings(current.copyWith(notificationsEnabled: enabled));
  }
}
