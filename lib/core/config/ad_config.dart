import 'dart:io';

/// AdMob reklam konfigürasyonu.
class AdConfig {
  AdConfig._();

  // Test reklam ID'leri (debug modda kullanılır)
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
    throw UnsupportedError('Desteklenmeyen platform');
  }

  // Reklam yükleme zaman aşımı
  static const Duration adLoadTimeout = Duration(seconds: 10);

  // Non-personalized ads default
  static const bool useNonPersonalizedAdsDefault = true;
}
