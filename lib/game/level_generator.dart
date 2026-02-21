import 'dart:math';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/game/level_configs.dart';

// ============================================================
// MOVE THE BLOCK: SLIDE PUZZLE
// DETERMİNİSTİK + SINIRSIS LEVEL ÜRETECİ — v2
// ============================================================
//
// Mimari:
//   1. level_configs.dart → L1-100 için sabit, tasarlanmış config
//   2. _configForLevel(n)  → L101+ için formül tabanlı dinamik config
//   3. globalSeed + n      → her cihazda aynı leveli üretir
//   4. BFS solver          → %100 çözülebilirlik garantisi
//   5. Minimum complexity  → trivial çözümler ayıklanır
//
// Üretim komutları:
//   dart run bin/generate_levels.dart       → 100 leveli bak/üret
//   dart run bin/generate_levels.dart 200   → 200 levele kadar üret
// ============================================================

// Şekil kısayolları (level_configs ile tutarlı)
const _h12 = (1, 2);
const _v21 = (2, 1);
const _s11 = (1, 1);
const _h13 = (1, 3);
const _v31 = (3, 1);
const _b22 = (2, 2);

const _allShapes = [_h12, _v21, _s11, _h13, _v31, _b22];

class LevelGenerator {
  /// Global seed — DEĞİŞTİRİLMEMELİ. Değiştirilirse tüm leveller değişir.
  static const int _globalSeed = 20260207;

  /// Deterministik RNG.
  static Random _rngForLevel(int n) => Random(_globalSeed * 1000 + n);

  // ────────────────────────────────────────────────────────────
  // TOPLU ÜRETİM
  // ────────────────────────────────────────────────────────────

  /// [count] adet leveli üret.
  static List<PuzzleLevel> generateBatch(int count) =>
      List.generate(count, (i) => generate(levelNumber: i + 1));

  // ────────────────────────────────────────────────────────────
  // TEK LEVEL ÜRETİM
  // ────────────────────────────────────────────────────────────

  /// Tek level üret — L1-100 config'den, L101+ formülden.
  static PuzzleLevel generate({required int levelNumber}) {
    final config = _configForLevel(levelNumber);
    final rng = _rngForLevel(levelNumber);
    final gridSize = config.gridSize;

    final bfsMaxStates = _bfsCapacity(gridSize);

    for (int attempt = 0; attempt < 300; attempt++) {
      final result = _tryGenerate(
        rng: rng,
        config: config,
        bfsMaxStates: bfsMaxStates,
        levelNumber: levelNumber,
      );
      if (result != null) {
        return PuzzleLevel(
          levelNumber: levelNumber,
          season: _seasonFor(levelNumber),
          gridRows: gridSize,
          gridCols: gridSize,
          maxMoves: result.optimalMoves + config.extraMoves,
          optimalMoves: result.optimalMoves,
          initialBlocks: result.blocks,
          exitRow: result.exitRow,
          exitCol: gridSize,
          difficultyTier: config.difficulty.label,
        );
      }
    }

    return _fallbackLevel(levelNumber, gridSize);
  }

  // ────────────────────────────────────────────────────────────
  // CONFIG SEÇICI — L101+ için formül
  // ────────────────────────────────────────────────────────────

  /// L1-100 → statik config. L101+ → prosedürel config.
  static LevelConfig _configForLevel(int n) {
    if (n >= 1 && n <= allLevelConfigs.length) return allLevelConfigs[n - 1];

    // ── L101+ : formül tabanlı, 8x8 grid ─────────────────────
    // chapter: her 10 level bir bölüm. chapter=0 → L101-110.
    final chapter = (n - 101) ~/ 10;
    final posInChapter = (n - 101) % 10; // 0-9

    // Blok sayısı: L101'de 7'den başlar, her chapter'da +1 (max 14)
    final blockCount = (7 + chapter).clamp(7, 14);

    // optimalMin: L101'de 6. Her 2 chapter'da +1 (max 16)
    final optimalMin = (6 + chapter ~/ 2).clamp(6, 16);

    // extraMoves: L101'de 4. Her 4 chapter'da -1 (min 2)
    final extraMoves = (4 - chapter ~/ 4).clamp(2, 4);

    // Bölge içi sawtooth: ilk level kolay giriş, son level boss
    final isChapterStart = posInChapter == 0;
    final isChapterBoss = posInChapter == 9;
    final adjOptMin = isChapterStart
        ? (optimalMin - 1).clamp(4, 16)
        : isChapterBoss
        ? (optimalMin + 1).clamp(6, 16)
        : optimalMin;
    final adjExtra = isChapterStart ? extraMoves + 2 : extraMoves;
    final adjBlocks = isChapterStart
        ? (blockCount - 2).clamp(5, 14)
        : isChapterBoss
        ? (blockCount + 1).clamp(7, 14)
        : blockCount;

    return LevelConfig(
      level: n,
      gridSize: 8,
      blockCount: adjBlocks,
      optimalMin: adjOptMin,
      optimalMax: adjOptMin + 3,
      extraMoves: adjExtra,
      shapes: _allShapes,
      difficulty: isChapterBoss
          ? DifficultyTier.boss
          : isChapterStart
          ? DifficultyTier.easy
          : chapter >= 4
          ? DifficultyTier.expert
          : DifficultyTier.hard,
    );
  }

  /// Season numarası: her 50 level bir sezon.
  static int _seasonFor(int levelNumber) => (levelNumber - 1) ~/ 50 + 1;

  /// BFS kapasitesi grid boyutuna göre.
  static int _bfsCapacity(int gridSize) => switch (gridSize) {
    5 => 20000,
    6 => 30000,
    7 => 45000,
    _ => 65000, // 8x8+
  };

  // ────────────────────────────────────────────────────────────
  // PUZZLE ÜRETİM
  // ────────────────────────────────────────────────────────────

  static _GenerationResult? _tryGenerate({
    required Random rng,
    required LevelConfig config,
    required int bfsMaxStates,
    required int levelNumber,
  }) {
    final gridSize = config.gridSize;
    final exitRow = gridSize ~/ 2;

    // Top başlangıç pozisyonu: sol yarı
    final maxBallCol = (gridSize ~/ 2).clamp(1, gridSize - 2);
    final ballCol = rng.nextInt(maxBallCol);
    final ball = Block(
      id: 'ball',
      row: exitRow,
      col: ballCol,
      width: 1,
      height: 1,
      type: BlockType.ball,
    );

    final blocks = <Block>[ball];
    int idCounter = 0;

    // Çıkış yolunda mutlaka bir bloker
    final blockerPlaced = _placeBlockerOnExitRow(
      rng: rng,
      blocks: blocks,
      gridSize: gridSize,
      exitRow: exitRow,
      ballCol: ballCol,
      id: 'obs_${idCounter++}',
    );
    if (!blockerPlaced) return null;

    // Kalan blokları rastgele yerleştir
    final remaining = config.blockCount - 1;
    for (int i = 0; i < remaining; i++) {
      final block = _tryPlaceRandomBlock(
        rng: rng,
        blocks: blocks,
        gridSize: gridSize,
        id: 'obs_${idCounter++}',
        shapes: config.shapes,
      );
      if (block != null) blocks.add(block);
    }

    if (blocks.length < 3) return null;

    final optimal = _bfsSolve(blocks, gridSize, exitRow, bfsMaxStates);
    if (optimal == null) return null;

    // ── Minimum complexity guard ──────────────────────────────
    // L6+ için: 1 hamlede çözülebilen bulmacaları reddet.
    // Aralık kontrolü de burada.
    if (optimal < config.optimalMin || optimal > config.optimalMax) return null;
    if (levelNumber > 5 && optimal <= 1) return null;

    return _GenerationResult(
      blocks: List<Block>.unmodifiable(blocks),
      exitRow: exitRow,
      optimalMoves: optimal,
    );
  }

  // ────────────────────────────────────────────────────────────
  // BLOK YERLEŞTİRME
  // ────────────────────────────────────────────────────────────

  static bool _placeBlockerOnExitRow({
    required Random rng,
    required List<Block> blocks,
    required int gridSize,
    required int exitRow,
    required int ballCol,
    required String id,
  }) {
    // 30 deneme: dikey bloker exit row üzerinde
    for (int attempt = 0; attempt < 30; attempt++) {
      final minCol = ballCol + 1;
      final maxCol = gridSize - 1;
      if (minCol > maxCol) return false;

      final col = minCol + rng.nextInt(maxCol - minCol + 1);
      final height = 2 + rng.nextInt(2);
      final minTopRow = (exitRow - height + 1).clamp(0, gridSize - height);
      final maxTopRow = exitRow.clamp(0, gridSize - height);
      if (minTopRow > maxTopRow) continue;

      final topRow = minTopRow + rng.nextInt(maxTopRow - minTopRow + 1);
      final block = Block(
        id: id,
        row: topRow,
        col: col,
        width: 1,
        height: height,
        type: BlockType.obstacle,
      );
      if (!_overlaps(block, blocks, gridSize)) {
        blocks.add(block);
        return true;
      }
    }

    // Fallback: yatay 1x1 bloker
    for (int col = ballCol + 1; col < gridSize; col++) {
      final block = Block(
        id: id,
        row: exitRow,
        col: col,
        width: 1,
        height: 1,
        type: BlockType.obstacle,
      );
      if (!_overlaps(block, blocks, gridSize)) {
        blocks.add(block);
        return true;
      }
    }
    return false;
  }

  static Block? _tryPlaceRandomBlock({
    required Random rng,
    required List<Block> blocks,
    required int gridSize,
    required String id,
    required List<(int, int)> shapes,
  }) {
    for (int attempt = 0; attempt < 40; attempt++) {
      final shape = shapes[rng.nextInt(shapes.length)];
      final height = shape.$1;
      final width = shape.$2;
      if (height > gridSize || width > gridSize) continue;

      final row = rng.nextInt(gridSize - height + 1);
      final col = rng.nextInt(gridSize - width + 1);
      final block = Block(
        id: id,
        row: row,
        col: col,
        width: width,
        height: height,
        type: BlockType.obstacle,
      );
      if (!_overlaps(block, blocks, gridSize)) return block;
    }
    return null;
  }

  static bool _overlaps(Block newBlock, List<Block> existing, int gridSize) {
    final occ = PuzzleEngine.buildOccupancy(existing, gridSize, gridSize);
    for (final cell in newBlock.occupiedCells) {
      if (cell.row < 0 ||
          cell.row >= gridSize ||
          cell.col < 0 ||
          cell.col >= gridSize) {
        return true;
      }
      if (occ[cell.row][cell.col] != null) return true;
    }
    return false;
  }

  // ────────────────────────────────────────────────────────────
  // BFS SOLVER
  // ────────────────────────────────────────────────────────────

  static int? _bfsSolve(
    List<Block> initialBlocks,
    int gridSize,
    int exitRow,
    int maxStates,
  ) {
    final initialHash = PuzzleEngine.stateHash(initialBlocks);
    final visited = <String>{initialHash};
    final queue = <_BfsState>[_BfsState(blocks: initialBlocks, moves: 0)];

    int head = 0;
    while (head < queue.length && visited.length < maxStates) {
      final current = queue[head++];

      for (final block in current.blocks) {
        for (final dir in Direction.values) {
          final result = PuzzleEngine.slideBlock(
            currentBlocks: current.blocks,
            blockId: block.id,
            direction: dir,
            gridRows: gridSize,
            gridCols: gridSize,
            exitRow: exitRow,
          );
          if (result.distance == 0) continue;
          if (result.solved) return current.moves + 1;

          final hash = PuzzleEngine.stateHash(result.blocks);
          if (!visited.contains(hash)) {
            visited.add(hash);
            queue.add(
              _BfsState(blocks: result.blocks, moves: current.moves + 1),
            );
          }
        }
      }
    }
    return null;
  }

  // ────────────────────────────────────────────────────────────
  // FALLBACK LEVEL
  // ────────────────────────────────────────────────────────────

  static PuzzleLevel _fallbackLevel(int levelNumber, int gridSize) {
    final exitRow = gridSize ~/ 2;
    return PuzzleLevel(
      levelNumber: levelNumber,
      season: _seasonFor(levelNumber),
      gridRows: gridSize,
      gridCols: gridSize,
      maxMoves: 5,
      optimalMoves: 3,
      initialBlocks: [
        Block(
          id: 'ball',
          row: exitRow,
          col: 0,
          width: 1,
          height: 1,
          type: BlockType.ball,
        ),
        Block(
          id: 'obs_0',
          row: (exitRow - 1).clamp(0, gridSize - 2),
          col: gridSize ~/ 2,
          width: 1,
          height: 2,
          type: BlockType.obstacle,
        ),
        Block(
          id: 'obs_1',
          row: exitRow,
          col: gridSize - 2,
          width: 1,
          height: 1,
          type: BlockType.obstacle,
        ),
      ],
      exitRow: exitRow,
      exitCol: gridSize,
      difficultyTier: DifficultyTier.easy.label,
    );
  }
}

// ============================================================
// İç yardımcılar
// ============================================================

class _GenerationResult {
  final List<Block> blocks;
  final int exitRow;
  final int optimalMoves;

  const _GenerationResult({
    required this.blocks,
    required this.exitRow,
    required this.optimalMoves,
  });
}

class _BfsState {
  final List<Block> blocks;
  final int moves;

  const _BfsState({required this.blocks, required this.moves});
}
