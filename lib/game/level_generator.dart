import 'dart:math';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/game/level_configs.dart';

// ============================================================
// MOVE THE BLOCK: SLIDE PUZZLE — DETERMİNİSTİK LEVEL ÜRETECİ
// ============================================================
// Konfigürasyon tabanlı + deterministik seed.
//
//   1. level_configs.dart → her levelin parametreleri (grid, blok, zorluk)
//   2. globalSeed + levelNumber → deterministik Random
//   3. BFS solver → %100 çözülebilirlik garantisi
//
// Kullanım:
//   - Geliştirme: bin/generate_levels.dart scripti çalıştırılır
//   - Uygulama: assets/levels.json'dan okunur (anlık yükleme)
// ============================================================

class LevelGenerator {
  /// Global seed — tüm cihazlarda aynı levelleri üretir.
  /// ⚠️ DEĞİŞTİRİLMEMELİ — aksi halde tüm leveller değişir!
  static const int _globalSeed = 20260207;

  /// Her level için deterministik Random üreteci.
  static Random _rngForLevel(int levelNumber) {
    return Random(_globalSeed * 1000 + levelNumber);
  }

  /// Toplu üretim: tüm 100 leveli config dosyasından üret.
  static List<PuzzleLevel> generateBatch(int count) {
    final levels = <PuzzleLevel>[];
    for (int i = 1; i <= count; i++) {
      levels.add(generate(levelNumber: i));
    }
    return levels;
  }

  /// Tek level üret — config dosyasından parametreleri okur.
  static PuzzleLevel generate({required int levelNumber}) {
    final config = allLevelConfigs[levelNumber - 1];
    final rng = _rngForLevel(levelNumber);
    final gridSize = config.gridSize;

    final bfsMaxStates = switch (gridSize) {
      5 => 20000,
      6 => 30000,
      _ => 40000,
    };

    for (int attempt = 0; attempt < 200; attempt++) {
      final result = _tryGenerate(
        rng: rng,
        gridSize: gridSize,
        blockCount: config.blockCount,
        targetOptimalMin: config.optimalMin,
        targetOptimalMax: config.optimalMax,
        shapes: config.shapes,
        bfsMaxStates: bfsMaxStates,
      );

      if (result != null) {
        return PuzzleLevel(
          levelNumber: levelNumber,
          season: 1,
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
  // PUZZLE ÜRETİM
  // ────────────────────────────────────────────────────────────

  static _GenerationResult? _tryGenerate({
    required Random rng,
    required int gridSize,
    required int blockCount,
    required int targetOptimalMin,
    required int targetOptimalMax,
    required List<(int, int)> shapes,
    required int bfsMaxStates,
  }) {
    final exitRow = gridSize ~/ 2;

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

    final blockerPlaced = _placeBlockerOnExitRow(
      rng: rng,
      blocks: blocks,
      gridSize: gridSize,
      exitRow: exitRow,
      ballCol: ballCol,
      id: 'obs_${idCounter++}',
    );
    if (!blockerPlaced) return null;

    final remaining = blockCount - 1;
    for (int i = 0; i < remaining; i++) {
      final block = _tryPlaceRandomBlock(
        rng: rng,
        blocks: blocks,
        gridSize: gridSize,
        id: 'obs_${idCounter++}',
        shapes: shapes,
      );
      if (block != null) {
        blocks.add(block);
      }
    }

    if (blocks.length < 3) return null;

    final optimal = _bfsSolve(blocks, gridSize, exitRow, bfsMaxStates);
    if (optimal == null) return null;
    if (optimal < targetOptimalMin || optimal > targetOptimalMax) return null;

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
    for (int attempt = 0; attempt < 30; attempt++) {
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

      if (!_overlaps(block, blocks, gridSize)) {
        return block;
      }
    }
    return null;
  }

  static bool _overlaps(Block newBlock, List<Block> existing, int gridSize) {
    final occ = PuzzleEngine.buildOccupancy(existing, gridSize, gridSize);
    for (final cell in newBlock.occupiedCells) {
      if (cell.row < 0 || cell.row >= gridSize ||
          cell.col < 0 || cell.col >= gridSize) {
        return true;
      }
      if (occ[cell.row][cell.col] != null) {
        return true;
      }
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
    final queue = <_BfsState>[
      _BfsState(blocks: initialBlocks, moves: 0),
    ];

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

          if (result.solved) {
            return current.moves + 1;
          }

          final hash = PuzzleEngine.stateHash(result.blocks);
          if (!visited.contains(hash)) {
            visited.add(hash);
            queue.add(_BfsState(
              blocks: result.blocks,
              moves: current.moves + 1,
            ));
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
      season: 1,
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
    );
  }
}

// ============================================================
// İÇ YARDIMCI SINIFLAR
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
