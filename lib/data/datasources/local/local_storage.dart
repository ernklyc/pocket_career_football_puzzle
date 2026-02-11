import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';
import 'package:pocket_career_football_puzzle/core/logging/logger.dart';
import 'package:pocket_career_football_puzzle/core/utils/guards.dart';

/// Local storage veri erişim katmanı.
/// Tüm kalıcı veri SharedPreferences üzerinden yönetilir.
class LocalStorage {
  static const String _keySchemaVersion = 'schemaVersion';
  static const String _keyOnboardingCompleted = 'onboardingCompleted';
  static const String _keyCachedPremium = 'cachedEntitlementPremium';
  static const String _keyCoinBalance = 'coinBalance';
  static const String _keyInventory = 'inventory';
  static const String _keyCareers = 'careers';
  static const String _keyActiveCareerIndex = 'activeCareerIndex';
  static const String _keyProgress = 'progress';
  static const String _keySettings = 'settings';
  static const String _keyTransactionLog = 'transactionLog';
  static const String _keyLocalLeaderboard = 'localLeaderboard';
  static const String _keyHighScores = 'highScores';
  static const String _keyRewardedAdLastWatch = 'rewardedAdLastWatch';
  static const String _keyRewardedAdDailyCount = 'rewardedAdDailyCount';
  static const String _keyRewardedAdCountDate = 'rewardedAdCountDate';
  static const String _keyLivesCount = 'livesCount';
  static const String _keyLastLifeRegenTime = 'lastLifeRegenTime';
  static const String _keySeenAchievements = 'seenAchievements';
  // (fixed levels artık assets/levels.json'dan okunuyor)

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateIfNeeded();
  }

  Future<void> _migrateIfNeeded() async {
    final storedVersion = _prefs.getInt(_keySchemaVersion) ?? 0;
    if (storedVersion < AppConfig.schemaVersion) {
      AppLogger.info('Schema migration: $storedVersion → ${AppConfig.schemaVersion}');
      // Migration logic burada
      await _prefs.setInt(_keySchemaVersion, AppConfig.schemaVersion);
    }
  }

  // --- Onboarding ---
  bool get onboardingCompleted => _prefs.getBool(_keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(_keyOnboardingCompleted, value);

  // --- Premium Cache ---
  bool get cachedPremium => _prefs.getBool(_keyCachedPremium) ?? false;
  Future<void> setCachedPremium(bool value) =>
      _prefs.setBool(_keyCachedPremium, value);

  // --- Coin Balance ---
  int get coinBalance {
    final balance = _prefs.getInt(_keyCoinBalance) ?? EconomyConfig.initialCoinBalance;
    return Guards.clampCoinBalance(balance);
  }

  Future<void> setCoinBalance(int balance) =>
      _prefs.setInt(_keyCoinBalance, Guards.clampCoinBalance(balance));

  // --- Careers ---
  String? get careersJson => _prefs.getString(_keyCareers);
  Future<void> setCareersJson(String json) => _prefs.setString(_keyCareers, json);

  int get activeCareerIndex => _prefs.getInt(_keyActiveCareerIndex) ?? -1;
  Future<void> setActiveCareerIndex(int index) =>
      _prefs.setInt(_keyActiveCareerIndex, index);

  // --- Inventory ---
  String? get inventoryJson => _prefs.getString(_keyInventory);
  Future<void> setInventoryJson(String json) =>
      _prefs.setString(_keyInventory, json);

  // --- Progress ---
  String? get progressJson => _prefs.getString(_keyProgress);
  Future<void> setProgressJson(String json) =>
      _prefs.setString(_keyProgress, json);

  // --- Per-Career Progress ---
  String? getCareerProgressJson(String careerId) =>
      _prefs.getString('progress_$careerId');
  Future<void> setCareerProgressJson(String careerId, String json) =>
      _prefs.setString('progress_$careerId', json);
  Future<void> removeCareerProgress(String careerId) =>
      _prefs.remove('progress_$careerId');

  // --- Active Cosmetics ---
  static const String _keyActiveCosmetics = 'activeCosmetics';
  String? get activeCosmeticsJson => _prefs.getString(_keyActiveCosmetics);
  Future<void> setActiveCosmeticsJson(String json) =>
      _prefs.setString(_keyActiveCosmetics, json);

  // --- Settings ---
  String? get settingsJson => _prefs.getString(_keySettings);
  Future<void> setSettingsJson(String json) =>
      _prefs.setString(_keySettings, json);

  // --- Transaction Log ---
  List<String> get transactionLog =>
      _prefs.getStringList(_keyTransactionLog) ?? [];
  Future<void> setTransactionLog(List<String> log) =>
      _prefs.setStringList(_keyTransactionLog, log);

  Future<void> addTransaction(String transactionJson) async {
    final log = transactionLog;
    log.add(transactionJson);
    // Rolling window: max 100 son işlem
    if (log.length > 100) {
      log.removeRange(0, log.length - 100);
    }
    await setTransactionLog(log);
  }

  // --- Local Leaderboard ---
  String? get localLeaderboardJson => _prefs.getString(_keyLocalLeaderboard);
  Future<void> setLocalLeaderboardJson(String json) =>
      _prefs.setString(_keyLocalLeaderboard, json);

  // --- High Scores (level bazlı) ---
  Map<String, int> get highScores {
    final json = _prefs.getString(_keyHighScores);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> setHighScore(String levelKey, int score) async {
    final scores = highScores;
    final currentBest = scores[levelKey] ?? 0;
    if (score > currentBest) {
      scores[levelKey] = score;
      await _prefs.setString(_keyHighScores, jsonEncode(scores));
    }
  }

  bool isNewRecord(String levelKey, int score) {
    final currentBest = highScores[levelKey] ?? 0;
    return score > currentBest;
  }

  // --- Rewarded Ad Tracking ---
  DateTime? get rewardedAdLastWatch {
    final ms = _prefs.getInt(_keyRewardedAdLastWatch);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> setRewardedAdLastWatch(DateTime time) =>
      _prefs.setInt(_keyRewardedAdLastWatch, time.millisecondsSinceEpoch);

  int get rewardedAdDailyCount {
    final dateStr = _prefs.getString(_keyRewardedAdCountDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (dateStr != today) return 0;
    return _prefs.getInt(_keyRewardedAdDailyCount) ?? 0;
  }

  // --- Lives (can) ---
  int get livesCount => _prefs.getInt(_keyLivesCount) ?? 10;
  Future<void> setLivesCount(int count) => _prefs.setInt(_keyLivesCount, count);

  int? get lastLifeRegenTimeMs {
    final ms = _prefs.getInt(_keyLastLifeRegenTime);
    return ms;
  }

  Future<void> setLastLifeRegenTime(int ms) =>
      _prefs.setInt(_keyLastLifeRegenTime, ms);

  Future<void> incrementRewardedAdCount() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dateStr = _prefs.getString(_keyRewardedAdCountDate);
    int count;
    if (dateStr != today) {
      count = 1;
      await _prefs.setString(_keyRewardedAdCountDate, today);
    } else {
      count = (_prefs.getInt(_keyRewardedAdDailyCount) ?? 0) + 1;
    }
    await _prefs.setInt(_keyRewardedAdDailyCount, count);
  }

  // --- Clear ---
  Future<void> clearAll() => _prefs.clear();

  // --- Seen Achievements ---
  List<String> get seenAchievements =>
      _prefs.getStringList(_keySeenAchievements) ?? [];

  Future<void> addSeenAchievement(String achievementId) async {
    final list = seenAchievements;
    if (!list.contains(achievementId)) {
      list.add(achievementId);
      await _prefs.setStringList(_keySeenAchievements, list);
    }
  }

  Future<void> clearSeenAchievements() =>
      _prefs.remove(_keySeenAchievements);
}
