import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/data/datasources/local/local_storage.dart';
import 'package:pocket_career_football_puzzle/data/repositories/level_repository.dart';
import 'package:pocket_career_football_puzzle/services/ads_service.dart';
import 'package:pocket_career_football_puzzle/services/auth_service.dart';
import 'package:pocket_career_football_puzzle/services/career_service.dart';
import 'package:pocket_career_football_puzzle/services/currency_service.dart';
import 'package:pocket_career_football_puzzle/services/lives_service.dart';
import 'package:pocket_career_football_puzzle/services/progress_service.dart';
import 'package:pocket_career_football_puzzle/services/purchases_service.dart';
import 'package:pocket_career_football_puzzle/services/session_service.dart';
import 'package:pocket_career_football_puzzle/services/settings_service.dart';
import 'package:pocket_career_football_puzzle/domain/entities/career.dart';
import 'package:pocket_career_football_puzzle/domain/entities/game_settings.dart';
import 'package:pocket_career_football_puzzle/domain/entities/session_result.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/domain/entities/transaction.dart';
import 'package:pocket_career_football_puzzle/domain/entities/active_cosmetics.dart';

// ===== Core Service Providers =====

final localStorageProvider = Provider<LocalStorage>((ref) {
  return LocalStorage();
});

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService(ref.watch(localStorageProvider));
});

final careerServiceProvider = Provider<CareerService>((ref) {
  return CareerService(ref.watch(localStorageProvider));
});

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService(ref.watch(localStorageProvider));
});

final levelRepositoryProvider = Provider<LevelRepository>((ref) {
  return LevelRepository();
});

final livesServiceProvider = Provider<LivesService>((ref) {
  return LivesService(ref.watch(localStorageProvider));
});

final livesProvider = StateNotifierProvider<LivesNotifier, int>((ref) {
  return LivesNotifier(ref.watch(livesServiceProvider));
});

class LivesNotifier extends StateNotifier<int> {
  final LivesService _service;

  LivesNotifier(this._service) : super(_service.livesSync);

  Future<void> refresh() async {
    state = await _service.getLives();
  }

  Future<bool> spendLife() async {
    final ok = await _service.spendLife();
    if (ok) state = _service.livesSync;
    return ok;
  }
}

final sessionServiceProvider = Provider<SessionService>((ref) {
  return SessionService();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.watch(localStorageProvider));
});

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService(ref.watch(localStorageProvider));
});

final purchasesServiceProvider = Provider<PurchasesService>((ref) {
  return PurchasesService(ref.watch(localStorageProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ===== App Bootstrap =====

final appBootstrapProvider = FutureProvider<bool>((ref) async {
  final storage = ref.read(localStorageProvider);
  await storage.init();

  // Sabit levelleri yükle/üret
  final levelRepo = ref.read(levelRepositoryProvider);
  await levelRepo.init();

  final ads = ref.read(adsServiceProvider);
  await ads.initialize();

  final purchases = ref.read(purchasesServiceProvider);
  await purchases.initialize();

  // Premium durumu ads service'e bildir
  ads.setPremiumActive(purchases.isPremium);

  return true;
});

// ===== Onboarding =====

final onboardingCompletedProvider = StateProvider<bool>((ref) {
  return ref.watch(localStorageProvider).onboardingCompleted;
});

// ===== Coin Balance =====

final coinBalanceProvider = StateNotifierProvider<CoinBalanceNotifier, int>((ref) {
  return CoinBalanceNotifier(ref.watch(currencyServiceProvider));
});

class CoinBalanceNotifier extends StateNotifier<int> {
  final CurrencyService _service;

  CoinBalanceNotifier(this._service) : super(_service.balance);

  Future<void> addCoins(int amount, String reason, TransactionSource source) async {
    state = await _service.addCoins(amount: amount, reason: reason, source: source);
  }

  Future<bool> spendCoins(int amount, String reason, TransactionSource source) async {
    final success = await _service.spendCoins(amount: amount, reason: reason, source: source);
    if (success) {
      state = _service.balance;
    }
    return success;
  }

  void refresh() {
    state = _service.balance;
  }
}

// ===== Entitlement (Premium) =====

final entitlementProvider = StateProvider<bool>((ref) {
  return ref.watch(purchasesServiceProvider).isPremium;
});

// ===== Settings =====

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, GameSettings>((ref) {
  return SettingsNotifier(ref.watch(settingsServiceProvider));
});

class SettingsNotifier extends StateNotifier<GameSettings> {
  final SettingsService _service;

  SettingsNotifier(this._service) : super(_service.loadSettings());

  Future<void> updateLanguage(String language) async {
    state = state.copyWith(language: language);
    await _service.saveSettings(state);
  }

  Future<void> toggleMusic(bool enabled) async {
    state = state.copyWith(musicEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> toggleHaptics(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _service.saveSettings(state);
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _service.saveSettings(state);
  }
}

// ===== Careers (tek kariyer) =====

final careersProvider =
    StateNotifierProvider<CareersNotifier, Career?>((ref) {
  return CareersNotifier(ref.watch(careerServiceProvider));
});

class CareersNotifier extends StateNotifier<Career?> {
  final CareerService _service;

  CareersNotifier(this._service) : super(_service.activeCareer);

  /// Kariyer var mı kontrolü.
  bool get hasCareer => state != null;

  Future<void> createCareer({
    required String playerName,
    required int playerAge,
    required String position,
    required String teamId,
    String teamName = '',
  }) async {
    await _service.createCareer(
      playerName: playerName,
      playerAge: playerAge,
      position: position,
      teamId: teamId,
      teamName: teamName,
    );
    state = _service.activeCareer;
  }

  /// Kariyeri sıfırla — tüm veriyi siler, sıfırdan açılır.
  Future<void> resetCareer() async {
    await _service.resetCareer();
    state = null;
  }

  void refresh() {
    state = _service.activeCareer;
  }

  Future<void> updatePlayerName(String newName) async {
    final career = _service.activeCareer;
    if (career != null) {
      await _service.updateCareer(career.copyWith(playerName: newName));
      state = _service.activeCareer;
    }
  }

  Future<void> updateTeamId(String newTeamId) async {
    final career = _service.activeCareer;
    if (career != null) {
      await _service.updateCareer(career.copyWith(teamId: newTeamId));
      state = _service.activeCareer;
    }
  }

  Future<void> updateTeamName(String newTeamName) async {
    final career = _service.activeCareer;
    if (career != null) {
      await _service.updateCareer(career.copyWith(teamName: newTeamName));
      state = _service.activeCareer;
    }
  }
}

final activeCareerProvider = Provider<Career?>((ref) {
  return ref.watch(careersProvider);
});

// ===== Progress (kariyer bazlı) =====

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressData>((ref) {
  final service = ref.watch(progressServiceProvider);
  final career = ref.watch(activeCareerProvider);
  service.setActiveCareerId(career?.id);
  return ProgressNotifier(service);
});

class ProgressNotifier extends StateNotifier<ProgressData> {
  final ProgressService _service;

  ProgressNotifier(this._service) : super(_service.loadProgress());

  Future<void> completeLevel({
    required int level,
    required int score,
    required int movesUsed,
    required int optimalMoves,
    required int maxMoves,
  }) async {
    state = await _service.completeLevel(
      level: level,
      score: score,
      movesUsed: movesUsed,
      optimalMoves: optimalMoves,
      maxMoves: maxMoves,
    );
  }

  bool isLevelUnlocked(int level) {
    return _service.isLevelUnlocked(level);
  }

  void refresh() {
    state = _service.loadProgress();
  }
}

// ===== Active Cosmetics =====

final activeCosmeticsProvider =
    StateNotifierProvider<ActiveCosmeticsNotifier, ActiveCosmetics>((ref) {
  return ActiveCosmeticsNotifier(ref.watch(localStorageProvider));
});

class ActiveCosmeticsNotifier extends StateNotifier<ActiveCosmetics> {
  final LocalStorage _storage;

  ActiveCosmeticsNotifier(this._storage) : super(_loadCosmetics(_storage));

  static ActiveCosmetics _loadCosmetics(LocalStorage storage) {
    final json = storage.activeCosmeticsJson;
    if (json != null) {
      return ActiveCosmetics.fromJsonString(json);
    }
    return const ActiveCosmetics();
  }

  Future<void> setBallSkin(String? skinId) async {
    state = state.copyWith(activeBallSkin: skinId, clearBallSkin: skinId == null);
    await _save();
  }

  Future<void> setBlockTheme(String? themeId) async {
    state = state.copyWith(activeBlockTheme: themeId, clearBlockTheme: themeId == null);
    await _save();
  }

  Future<void> setProfileBadge(String? badgeId) async {
    state = state.copyWith(activeProfileBadge: badgeId, clearProfileBadge: badgeId == null);
    await _save();
  }

  Future<void> _save() async {
    await _storage.setActiveCosmeticsJson(state.toJsonString());
  }
}

// ===== Auth =====

final authProvider = StateProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// ===== Game State =====

final currentGameStateProvider = StateProvider<PuzzleGameState?>((ref) {
  return null;
});

final lastSessionResultProvider = StateProvider<SessionResult?>((ref) {
  return null;
});

