// ============================================================
// 100 LEVELİN SABİT KONFİGÜRASYONU — v3 (Empirically Validated)
// ============================================================
// DifficultyTier: tutorial / easy / medium / hard / expert / boss
//
// Zorluk Eğrisi Prensibi:
//   - L1-5   : Gerçek tutorial — 2-3 blok, bol hamle
//   - L6-10  : Bölge 1 — giderek zorlaşır, L10 ilk boss
//   - Bölge başları (L11,21,31,41,51,61,71,81,91): yumuşak iniş
//   - L91-100: Expert bölgesi — son derece zorlu
//   - L100   : Ultimate Boss
//
// BFS Kısıtı (Ampirik, 7x7 300 deneme limiti):
//   optimalMin ≤ 6  →  tüm blockCount değerlerinde güvenilir
//   optimalMin = 7  →  blockCount ≤ 6 ile güvenilir, 7+ ile fallback
//
// Zorluk Sürücüleri:
//   - blockCount arttır    → daha fazla engel, daha karmaşık
//   - extraMoves azalt     → hamle toleransı daralır, daha sert
//   - optimalMin arttır    → 6'yı geçme (BFS güvenilirliği)
// ============================================================

enum DifficultyTier {
  tutorial,
  easy,
  medium,
  hard,
  expert,
  boss;

  String get label {
    switch (this) {
      case DifficultyTier.tutorial:
        return 'Öğretici';
      case DifficultyTier.easy:
        return 'Kolay';
      case DifficultyTier.medium:
        return 'Orta';
      case DifficultyTier.hard:
        return 'Zor';
      case DifficultyTier.expert:
        return 'Efsane';
      case DifficultyTier.boss:
        return 'Boss';
    }
  }
}

class LevelConfig {
  final int level;
  final int gridSize;
  final int blockCount;
  final int optimalMin;
  final int optimalMax;
  final int extraMoves;
  final List<(int, int)> shapes;
  final DifficultyTier difficulty;

  const LevelConfig({
    required this.level,
    required this.gridSize,
    required this.blockCount,
    required this.optimalMin,
    required this.optimalMax,
    required this.extraMoves,
    required this.shapes,
    required this.difficulty,
  });

  /// DS = optimalMin×10 + blockCount×5 − extraMoves×3
  int get difficultyScore => optimalMin * 10 + blockCount * 5 - extraMoves * 3;
}

// ── Şekil kısayolları ─────────────────────────────────────
const _h12 = (1, 2);
const _v21 = (2, 1);
const _s11 = (1, 1);
const _h13 = (1, 3);
const _v31 = (3, 1);
const _b22 = (2, 2);

// ── Şekil havuzları ───────────────────────────────────────
const _basic = [_h12, _v21];
const _withSmall = [_h12, _v21, _s11];
const _withLong = [_h12, _v21, _s11, _h13, _v31];
const _allShapes = [_h12, _v21, _s11, _h13, _v31, _b22];

// ── Tier kısaltmaları ─────────────────────────────────────
const _t = DifficultyTier.tutorial;
const _e = DifficultyTier.easy;
const _m = DifficultyTier.medium;
const _h = DifficultyTier.hard;
const _ex = DifficultyTier.expert;
const _b = DifficultyTier.boss;

/// Tüm 100 level konfigürasyonu.
final List<LevelConfig> allLevelConfigs = [
  // ═══════════════════════════════════════════════════════
  // BÖLGE 0: L1-5 — GERÇEK TUTORIAL
  // 5x5, 2-3 blok, çok geniş hamle toleransı.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 1,
    gridSize: 5,
    blockCount: 2,
    optimalMin: 2,
    optimalMax: 3,
    extraMoves: 12,
    shapes: _basic,
    difficulty: _t,
  ),
  LevelConfig(
    level: 2,
    gridSize: 5,
    blockCount: 2,
    optimalMin: 2,
    optimalMax: 3,
    extraMoves: 11,
    shapes: _basic,
    difficulty: _t,
  ),
  LevelConfig(
    level: 3,
    gridSize: 5,
    blockCount: 2,
    optimalMin: 2,
    optimalMax: 4,
    extraMoves: 10,
    shapes: _basic,
    difficulty: _t,
  ),
  LevelConfig(
    level: 4,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 4,
    extraMoves: 9,
    shapes: _basic,
    difficulty: _t,
  ),
  LevelConfig(
    level: 5,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 4,
    extraMoves: 8,
    shapes: _basic,
    difficulty: _t,
  ),

  // ═══════════════════════════════════════════════════════
  // BÖLGE 1: L6-10 — İLK GERÇEK BÖLGE (5x5)
  // L10 boss: 5 blok, dar hamle toleransı.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 6,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 7,
    shapes: _basic,
    difficulty: _e,
  ),
  LevelConfig(
    level: 7,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _basic,
    difficulty: _e,
  ),
  LevelConfig(
    level: 8,
    gridSize: 5,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _basic,
    difficulty: _m,
  ),
  LevelConfig(
    level: 9,
    gridSize: 5,
    blockCount: 4,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _basic,
    difficulty: _h,
  ),
  LevelConfig(
    level: 10,
    gridSize: 5,
    blockCount: 5,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _basic,
    difficulty: _b,
  ),

  // ═══════════════════════════════════════════════════════
  // BÖLGE 2: L11-20 — +1x1 KÜÇÜK KARE (5x5)
  // Soft landing L11. L20 boss: 6 blok, sıkı hamle.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 11,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 2,
    optimalMax: 4,
    extraMoves: 9,
    shapes: _withSmall,
    difficulty: _t,
  ),
  LevelConfig(
    level: 12,
    gridSize: 5,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _withSmall,
    difficulty: _e,
  ),
  LevelConfig(
    level: 13,
    gridSize: 5,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 7,
    shapes: _withSmall,
    difficulty: _e,
  ),
  LevelConfig(
    level: 14,
    gridSize: 5,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _withSmall,
    difficulty: _m,
  ),
  LevelConfig(
    level: 15,
    gridSize: 5,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _withSmall,
    difficulty: _m,
  ),
  LevelConfig(
    level: 16,
    gridSize: 5,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _withSmall,
    difficulty: _m,
  ),
  LevelConfig(
    level: 17,
    gridSize: 5,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _withSmall,
    difficulty: _h,
  ),
  LevelConfig(
    level: 18,
    gridSize: 5,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _withSmall,
    difficulty: _h,
  ),
  LevelConfig(
    level: 19,
    gridSize: 5,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _withSmall,
    difficulty: _h,
  ),
  LevelConfig(
    level: 20,
    gridSize: 5,
    blockCount: 6,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _withSmall,
    difficulty: _b,
  ),

  // ═══════════════════════════════════════════════════════
  // BÖLGE 3: L21-30 — 6x6 + UZUN BLOKLAR
  // Soft landing L21. L30 boss: 6 blok, optimalMin:6, extraMoves:3.
  // (optimalMin:7+blockCount:7 → fallback. Sabit: ≤6 geç değil.)
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 21,
    gridSize: 6,
    blockCount: 3,
    optimalMin: 2,
    optimalMax: 4,
    extraMoves: 9,
    shapes: _withLong,
    difficulty: _t,
  ),
  LevelConfig(
    level: 22,
    gridSize: 6,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _withLong,
    difficulty: _e,
  ),
  LevelConfig(
    level: 23,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 7,
    shapes: _withLong,
    difficulty: _e,
  ),
  LevelConfig(
    level: 24,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 25,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 26,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 27,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 28,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 29,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 30,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _withLong,
    difficulty: _b,
  ), // boss: extraMoves=3
  // ═══════════════════════════════════════════════════════
  // BÖLGE 4: L31-40 — 6x6 KARMA
  // Soft landing L31. L40 boss: 7 blok, optimalMin:6, extraMoves:3.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 31,
    gridSize: 6,
    blockCount: 3,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _withLong,
    difficulty: _e,
  ),
  LevelConfig(
    level: 32,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 7,
    shapes: _withLong,
    difficulty: _e,
  ),
  LevelConfig(
    level: 33,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 34,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 35,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _withLong,
    difficulty: _m,
  ),
  LevelConfig(
    level: 36,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 37,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 38,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 39,
    gridSize: 6,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _withLong,
    difficulty: _h,
  ),
  LevelConfig(
    level: 40,
    gridSize: 6,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _withLong,
    difficulty: _b,
  ), // boss: extraMoves=3
  // ═══════════════════════════════════════════════════════
  // BÖLGE 5: L41-50 — 6x6 + 2x2 BÜYÜK KARE
  // Soft landing L41. L50 boss: 7 blok, extraMoves:2.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 41,
    gridSize: 6,
    blockCount: 3,
    optimalMin: 2,
    optimalMax: 4,
    extraMoves: 9,
    shapes: _allShapes,
    difficulty: _t,
  ),
  LevelConfig(
    level: 42,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 43,
    gridSize: 6,
    blockCount: 4,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 44,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 45,
    gridSize: 6,
    blockCount: 5,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 46,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 47,
    gridSize: 6,
    blockCount: 6,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 48,
    gridSize: 6,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 49,
    gridSize: 6,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 50,
    gridSize: 6,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // boss: sadece 2 extra
  // ═══════════════════════════════════════════════════════
  // BÖLGE 6: L51-60 — 7x7 GİRİŞİ
  // Soft landing L51. L60 boss: 8 blok, extraMoves:2.
  // (optimalMin kesin ≤6 — 8 block + optimalMin:7 fallback)
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 51,
    gridSize: 7,
    blockCount: 3,
    optimalMin: 2,
    optimalMax: 4,
    extraMoves: 9,
    shapes: _allShapes,
    difficulty: _t,
  ),
  LevelConfig(
    level: 52,
    gridSize: 7,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 53,
    gridSize: 7,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 54,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 55,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 56,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 57,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 58,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 59,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 60,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // boss: 8 blok, sadece 2 extra
  // ═══════════════════════════════════════════════════════
  // BÖLGE 7: L61-70 — 7x7 ORTA YOĞUNLUK
  // Soft landing L61. L70 boss: 8 blok, extraMoves:2.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 61,
    gridSize: 7,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 62,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 63,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 64,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 65,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 66,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 67,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 68,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 69,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 70,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // boss: 8 blok, 2 extra
  // ═══════════════════════════════════════════════════════
  // BÖLGE 8: L71-80 — 7x7 YÜKSEK YOĞUNLUK
  // Soft landing L71. L80 boss: 9 blok, extraMoves:2.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 71,
    gridSize: 7,
    blockCount: 4,
    optimalMin: 3,
    optimalMax: 5,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 72,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 73,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 74,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 75,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 76,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 77,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 78,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 79,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 80,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // boss: 9 blok, 2 extra
  // ═══════════════════════════════════════════════════════
  // BÖLGE 9: L81-90 — 7x7 ÇOK YÜKSEK YOĞUNLUK
  // Soft landing L81. L90 boss: 9 blok, extraMoves:2.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 81,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 7,
    shapes: _allShapes,
    difficulty: _e,
  ),
  LevelConfig(
    level: 82,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 83,
    gridSize: 7,
    blockCount: 6,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 84,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 85,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 86,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 87,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 88,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 89,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 90,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // boss: 9 blok, 2 extra
  // ═══════════════════════════════════════════════════════
  // BÖLGE 10: L91-100 — EXPERT / ULTIMATE
  // Soft landing L91. L99: Efsane. L100: ULTIMATE BOSS.
  // Zorluk extraMoves:2'de kilitli, blockCount giderek artar.
  // optimalMin ≤6 — BFS güvenilirliği korunur.
  // ═══════════════════════════════════════════════════════
  LevelConfig(
    level: 91,
    gridSize: 7,
    blockCount: 5,
    optimalMin: 4,
    optimalMax: 6,
    extraMoves: 8,
    shapes: _allShapes,
    difficulty: _m,
  ),
  LevelConfig(
    level: 92,
    gridSize: 7,
    blockCount: 7,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 6,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 93,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 5,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 94,
    gridSize: 7,
    blockCount: 8,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _h,
  ),
  LevelConfig(
    level: 95,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 5,
    optimalMax: 7,
    extraMoves: 4,
    shapes: _allShapes,
    difficulty: _ex,
  ),
  LevelConfig(
    level: 96,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _ex,
  ),
  LevelConfig(
    level: 97,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 3,
    shapes: _allShapes,
    difficulty: _ex,
  ),
  LevelConfig(
    level: 98,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _ex,
  ),
  LevelConfig(
    level: 99,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _ex,
  ),
  LevelConfig(
    level: 100,
    gridSize: 7,
    blockCount: 9,
    optimalMin: 6,
    optimalMax: 8,
    extraMoves: 2,
    shapes: _allShapes,
    difficulty: _b,
  ), // ULTIMATE BOSS
];
