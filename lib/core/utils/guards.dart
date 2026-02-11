/// Değer doğrulama ve güvenlik yardımcıları.
class Guards {
  Guards._();

  /// Coin bakiyesinin negatif olmamasını garanti eder.
  static int clampCoinBalance(int balance) {
    if (balance < 0) return 0;
    return balance;
  }

  /// Level numarasının geçerli aralıkta olmasını garanti eder.
  static int clampLevel(int level, {int min = 1, int max = 999}) {
    return level.clamp(min, max);
  }

  /// Skor değerinin geçerli olmasını garanti eder.
  static int clampScore(int score) {
    if (score < 0) return 0;
    if (score > 999999) return 999999;
    return score;
  }

  /// Yaşın geçerli olmasını garanti eder.
  static int clampAge(int age) {
    return age.clamp(13, 99);
  }

  /// Boş olmayan string kontrolü.
  static String ensureNotEmpty(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value.trim();
  }

  /// Grid boyutunun geçerli olmasını garanti eder.
  static int clampGridSize(int size, {int min = 5, int max = 9}) {
    return size.clamp(min, max);
  }

  /// Hamle sayısının geçerli olmasını garanti eder.
  static int clampMoves(int moves, {int min = 1, int max = 50}) {
    return moves.clamp(min, max);
  }
}
