import 'package:equatable/equatable.dart';

// ============================================================
// MOVE THE BLOCK: SLIDE PUZZLE — Veri Modeli
// ============================================================
// Birden fazla blok var. Oyuncu herhangi bir bloğu seçip
// kaydırabilir (slide until hit). Amaç: topu (1x1 ana blok)
// sağ kenardaki çıkışa (kale) ulaştırmak.
// ============================================================

/// Dört ana yön.
enum Direction {
  up,
  down,
  left,
  right;

  int get dx {
    switch (this) {
      case Direction.left:
        return -1;
      case Direction.right:
        return 1;
      default:
        return 0;
    }
  }

  int get dy {
    switch (this) {
      case Direction.up:
        return -1;
      case Direction.down:
        return 1;
      default:
        return 0;
    }
  }

  Direction get opposite {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }
}

/// Grid pozisyonu.
class GridPosition extends Equatable {
  final int row;
  final int col;

  const GridPosition(this.row, this.col);

  GridPosition step(Direction dir) =>
      GridPosition(row + dir.dy, col + dir.dx);

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => '($row,$col)';
}

/// Maç sonucu — futbol puanlama sistemi.
enum MatchResult {
  /// Galibiyet: optimal hamlede tamamlandı → 3 puan
  win(3),

  /// Beraberlik: orta bant hamlede tamamlandı → 1 puan
  draw(1),

  /// Mağlubiyet: çok hamle kullanıldı → 0 puan
  loss(0);

  final int points;
  const MatchResult(this.points);
}

/// Blok türü.
enum BlockType {
  /// Top — oyuncunun çıkışa ulaştırması gereken ana blok (1x1).
  ball,

  /// Engel — hareket ettirilebilir bloklar. Yolu kapatır.
  obstacle,
}

/// Oyun tahtasındaki bir blok.
/// Sol-üst köşe (row, col) ve boyut (width x height).
class Block extends Equatable {
  final String id;
  final int row;
  final int col;
  final int width; // sütun sayısı
  final int height; // satır sayısı
  final BlockType type;

  const Block({
    required this.id,
    required this.row,
    required this.col,
    required this.width,
    required this.height,
    required this.type,
  });

  bool get isBall => type == BlockType.ball;

  /// Bu bloğun kapladığı tüm hücreleri döndürür.
  List<GridPosition> get occupiedCells {
    final cells = <GridPosition>[];
    for (int r = row; r < row + height; r++) {
      for (int c = col; c < col + width; c++) {
        cells.add(GridPosition(r, c));
      }
    }
    return cells;
  }

  /// Bloğu belirli yönde belirli mesafe kaydır.
  Block moved(Direction dir, int distance) {
    return Block(
      id: id,
      row: row + dir.dy * distance,
      col: col + dir.dx * distance,
      width: width,
      height: height,
      type: type,
    );
  }

  Block copyWith({int? row, int? col}) {
    return Block(
      id: id,
      row: row ?? this.row,
      col: col ?? this.col,
      width: width,
      height: height,
      type: type,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'row': row,
        'col': col,
        'width': width,
        'height': height,
        'type': type.name,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json['id'] as String,
        row: json['row'] as int,
        col: json['col'] as int,
        width: json['width'] as int,
        height: json['height'] as int,
        type: BlockType.values.byName(json['type'] as String),
      );

  @override
  List<Object?> get props => [id, row, col, width, height, type];
}

/// Bulmaca level tanımı.
class PuzzleLevel extends Equatable {
  final int levelNumber;
  final int season;
  final int gridRows;
  final int gridCols;
  final int maxMoves;
  final int optimalMoves;
  final List<Block> initialBlocks;
  final int exitRow; // Çıkış satırı (sağ kenarda)
  final int exitCol; // Çıkış sütunu (gridCols, yani grid dışı sağ kenar)
  final String? difficultyTier; // Config'den gelen zorluk etiketi

  const PuzzleLevel({
    required this.levelNumber,
    required this.season,
    required this.gridRows,
    required this.gridCols,
    required this.maxMoves,
    required this.optimalMoves,
    required this.initialBlocks,
    required this.exitRow,
    required this.exitCol,
    this.difficultyTier,
  });

  /// Zorluk etiketi (config'den gelen tier varsa onu kullan, yoksa hesapla).
  /// "Öğretici" → "Kolay" (game over ekranı ile uyumlu).
  String get difficultyLabel {
    if (difficultyTier != null) {
      if (difficultyTier == 'Öğretici') return 'Kolay';
      return difficultyTier!;
    }
    if (optimalMoves <= 3) return 'Kolay';
    if (optimalMoves <= 6) return 'Orta';
    if (optimalMoves <= 10) return 'Zor';
    return 'Çok Zor';
  }

  /// Bu levelde kullanılan blok şekillerinin özeti.
  List<String> get blockShapeDescriptions {
    final shapes = <String>{};
    for (final b in initialBlocks) {
      if (b.isBall) {
        continue;
      } else if (b.width == 1 && b.height == 1) {
        shapes.add('1x1 Küçük');
      } else if (b.width == 2 && b.height == 1) {
        shapes.add('2x1 Yatay');
      } else if (b.width == 1 && b.height == 2) {
        shapes.add('1x2 Dikey');
      } else if (b.width == 3 && b.height == 1) {
        shapes.add('3x1 Yatay Uzun');
      } else if (b.width == 1 && b.height == 3) {
        shapes.add('1x3 Dikey Uzun');
      } else if (b.width == 2 && b.height == 2) {
        shapes.add('2x2 Büyük');
      } else {
        shapes.add('${b.width}x${b.height}');
      }
    }
    return shapes.toList();
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'season': season,
        'gridRows': gridRows,
        'gridCols': gridCols,
        'maxMoves': maxMoves,
        'optimalMoves': optimalMoves,
        'initialBlocks': initialBlocks.map((b) => b.toJson()).toList(),
        'exitRow': exitRow,
        'exitCol': exitCol,
        if (difficultyTier != null) 'difficultyTier': difficultyTier,
      };

  factory PuzzleLevel.fromJson(Map<String, dynamic> json) => PuzzleLevel(
        levelNumber: json['levelNumber'] as int,
        season: json['season'] as int,
        gridRows: json['gridRows'] as int,
        gridCols: json['gridCols'] as int,
        maxMoves: json['maxMoves'] as int,
        optimalMoves: json['optimalMoves'] as int,
        initialBlocks: (json['initialBlocks'] as List)
            .map((b) => Block.fromJson(b as Map<String, dynamic>))
            .toList(),
        exitRow: json['exitRow'] as int,
        exitCol: json['exitCol'] as int,
        difficultyTier: json['difficultyTier'] as String?,
      );

  @override
  List<Object?> get props => [levelNumber, season];
}

/// Aktif oyun durumu.
class PuzzleGameState extends Equatable {
  final PuzzleLevel level;
  final List<Block> blocks;
  final int movesUsed;
  final bool isCompleted;
  final bool isFailed;
  final List<MoveRecord> moveHistory;

  const PuzzleGameState({
    required this.level,
    required this.blocks,
    this.movesUsed = 0,
    this.isCompleted = false,
    this.isFailed = false,
    this.moveHistory = const [],
  });

  int get movesRemaining => level.maxMoves - movesUsed;
  bool get canMove => !isCompleted && !isFailed && movesRemaining > 0;

  /// Top bloğunu bul.
  Block get ball => blocks.firstWhere((b) => b.isBall);

  PuzzleGameState copyWith({
    List<Block>? blocks,
    int? movesUsed,
    bool? isCompleted,
    bool? isFailed,
    List<MoveRecord>? moveHistory,
  }) {
    return PuzzleGameState(
      level: level,
      blocks: blocks ?? this.blocks,
      movesUsed: movesUsed ?? this.movesUsed,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  @override
  List<Object?> get props => [blocks, movesUsed, isCompleted, isFailed];
}

/// Bir hamlenin kaydı.
class MoveRecord extends Equatable {
  final String blockId;
  final Direction direction;
  final int distance;

  const MoveRecord({
    required this.blockId,
    required this.direction,
    required this.distance,
  });

  @override
  List<Object?> get props => [blockId, direction, distance];
}

// ============================================================
// PUZZLE ENGINE — Saf mantık fonksiyonları (UI'dan bağımsız)
// ============================================================

class PuzzleEngine {
  PuzzleEngine._();

  /// Occupancy grid oluştur: her hücrede hangi blok ID'si var (null = boş).
  static List<List<String?>> buildOccupancy(
      List<Block> blocks, int rows, int cols) {
    final grid = List.generate(rows, (_) => List<String?>.filled(cols, null));
    for (final block in blocks) {
      for (final cell in block.occupiedCells) {
        if (cell.row >= 0 && cell.row < rows && cell.col >= 0 && cell.col < cols) {
          grid[cell.row][cell.col] = block.id;
        }
      }
    }
    return grid;
  }

  /// Bir bloğun belirli yönde kaç kare kayabileceğini hesapla.
  /// Slide-until-hit: engele veya grid kenarına çarpana kadar.
  /// Top için: çıkışa ulaşma kontrolü dahil.
  static int maxSlideDistance(
    Block block,
    Direction dir,
    List<Block> allBlocks,
    int gridRows,
    int gridCols, {
    int? exitRow,
  }) {
    final occ = buildOccupancy(allBlocks, gridRows, gridCols);

    int distance = 0;
    while (true) {
      distance++;
      final moved = block.moved(dir, distance);

      // Top sağa kayarken çıkışa ulaşıyor mu?
      if (block.isBall && dir == Direction.right && exitRow != null) {
        if (moved.col >= gridCols && block.row == exitRow) {
          return distance;
        }
      }

      // Sınır kontrolü
      for (final cell in moved.occupiedCells) {
        if (cell.row < 0 || cell.row >= gridRows ||
            cell.col < 0 || cell.col >= gridCols) {
          return distance - 1;
        }
        // Başka blokla çarpışma (kendi hücreleri hariç)
        final occupant = occ[cell.row][cell.col];
        if (occupant != null && occupant != block.id) {
          return distance - 1;
        }
      }
    }
  }

  /// Bloğu kaydır ve yeni blok listesi döndür.
  /// Döndürdüğü değer: (yeniBlokListesi, kaymaDistansı, topÇıkışaUlaştıMı).
  static ({List<Block> blocks, int distance, bool solved}) slideBlock({
    required List<Block> currentBlocks,
    required String blockId,
    required Direction direction,
    required int gridRows,
    required int gridCols,
    required int exitRow,
  }) {
    final blockIndex = currentBlocks.indexWhere((b) => b.id == blockId);
    if (blockIndex == -1) {
      return (blocks: currentBlocks, distance: 0, solved: false);
    }

    final block = currentBlocks[blockIndex];
    final maxDist = maxSlideDistance(
      block,
      direction,
      currentBlocks,
      gridRows,
      gridCols,
      exitRow: exitRow,
    );

    if (maxDist == 0) {
      return (blocks: currentBlocks, distance: 0, solved: false);
    }

    // Topun çıkışa ulaşıp ulaşmadığını kontrol et
    bool solved = false;
    if (block.isBall && direction == Direction.right) {
      final movedBlock = block.moved(direction, maxDist);
      if (movedBlock.col >= gridCols && block.row == exitRow) {
        solved = true;
      }
    }

    // Yeni blok listesi
    final newBlocks = List<Block>.from(currentBlocks);
    if (solved) {
      // Top grid dışına çıkıyor (çıkıştan), kale hizasına koy görsel için
      newBlocks[blockIndex] = block.moved(direction, maxDist - 1);
    } else {
      newBlocks[blockIndex] = block.moved(direction, maxDist);
    }

    return (blocks: newBlocks, distance: maxDist, solved: solved);
  }

  /// Top çıkışa ulaştı mı?
  static bool isSolved(List<Block> blocks, int exitRow, int gridCols) {
    final ball = blocks.firstWhere((b) => b.isBall);
    // Top çıkış satırında ve sağ kenara ulaştıysa
    return ball.row == exitRow && ball.col >= gridCols - 1;
  }

  /// State hash: BFS solver için blok pozisyonlarının string temsili.
  static String stateHash(List<Block> blocks) {
    final sorted = List<Block>.from(blocks)
      ..sort((a, b) => a.id.compareTo(b.id));
    return sorted.map((b) => '${b.id}:${b.row},${b.col}').join('|');
  }
}
