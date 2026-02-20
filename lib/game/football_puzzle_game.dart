import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';

// ============================================================
// MOVE THE BLOCK: SLIDE PUZZLE — Flame Oyun Motoru
// ============================================================
// Kontroller:
//  - Bir bloğa dokun (drag start) → seçili blok
//  - Parmağı bir yöne sürükle → blok o yöne kayar (slide until hit)
//  - Boş alana dokunursan hiçbir şey olmaz
//  - Amaç: topu (1x1 beyaz blok) sağ kenardaki çıkışa ulaştırmak
// ============================================================

class FootballPuzzleGame extends FlameGame with DragCallbacks {
  final PuzzleLevel level;
  final void Function(MoveRecord move) onMove;
  final VoidCallback onGoal;
  final VoidCallback onFail;

  /// Kozmetik: top rengi (null = default beyaz)
  final Color? ballSkinColor;

  /// Kozmetik: blok teması renkleri (null = default)
  final Color? blockThemePrimary;
  final Color? blockThemeSecondary;

  late PuzzleGameState _state;

  // ── Layout ──
  late double _cellSize;
  late double _gridOffsetX;
  late double _gridOffsetY;

  /// Mantıksal içerik merkezi (dönüşüm için).
  late double _logicalCenterX;
  late double _logicalCenterY;

  // ── Drag & Selection ──
  Vector2? _dragStartPos;
  Vector2? _lastDragPos;
  String? _selectedBlockId;

  // ── Animasyon ──
  String? _animBlockId;
  Offset? _animFrom;
  Offset? _animTo;
  double _animProgress = 1.0;
  static const _animSpeed = 5.0;

  // ── Gol efekti ──
  bool _showGoalEffect = false;
  double _goalEffectProgress = 0.0;

  // ── Top kaleye girdi → sabit pozisyonda tut ──
  bool _goalScored = false;
  Offset? _goalBallPos;

  // ── Çim dokuları (açık/koyu yeşil) ──
  ui.Image? _grassLight;
  ui.Image? _grassDark;

  // ── Oyun alanı arka planı ──
  ui.Image? _gameBgImage;

  // ── Tahta blok görselleri ──
  /// 1x2 / 2x1 bloklar için: tabela.png
  ui.Image? _boardImage;

  /// 1x1 bloklar için: 1x1.png
  ui.Image? _board1x1Image;

  /// 1x3 / 3x1 bloklar için: 1x3.png
  ui.Image? _board1x3Image;

  // ── Top ve kale görselleri ──
  ui.Image? _ballImage;
  ui.Image? _goalImage;

  FootballPuzzleGame({
    required this.level,
    required this.onMove,
    required this.onGoal,
    required this.onFail,
    this.ballSkinColor,
    this.blockThemePrimary,
    this.blockThemeSecondary,
  });

  PuzzleGameState get gameState => _state;

  @override
  Color backgroundColor() => AppColors.background;

  @override
  Future<void> onLoad() async {
    _state = PuzzleGameState(
      level: level,
      blocks: List<Block>.from(level.initialBlocks),
    );
    _calculateLayout();
    // Çim dokularını ve tahta blok görselini yükle
    try {
      // Oyun alanı arka planı — tribün görseli
      final bgData = await rootBundle.load('assets/buttons/game_screen_bg.png');
      final bgCodec = await ui.instantiateImageCodec(
        bgData.buffer.asUint8List(),
      );
      final bgFrame = await bgCodec.getNextFrame();
      _gameBgImage = bgFrame.image;

      // Açık çim
      final lightData = await rootBundle.load('assets/buttons/light_green.png');
      final lightCodec = await ui.instantiateImageCodec(
        lightData.buffer.asUint8List(),
      );
      final lightFrame = await lightCodec.getNextFrame();
      _grassLight = lightFrame.image;

      // Koyu çim
      final darkData = await rootBundle.load('assets/buttons/dark_green.png');
      final darkCodec = await ui.instantiateImageCodec(
        darkData.buffer.asUint8List(),
      );
      final darkFrame = await darkCodec.getNextFrame();
      _grassDark = darkFrame.image;

      // Tahta blok (1x2 / 2x1) — 1x2.png
      final boardData = await rootBundle.load('assets/buttons/1x2.png');
      final boardCodec = await ui.instantiateImageCodec(
        boardData.buffer.asUint8List(),
      );
      final boardFrame = await boardCodec.getNextFrame();
      _boardImage = boardFrame.image;

      // Tahta 1x1 blok — 1x1.png
      final board1x1Data = await rootBundle.load('assets/buttons/1x1.png');
      final board1x1Codec = await ui.instantiateImageCodec(
        board1x1Data.buffer.asUint8List(),
      );
      final board1x1Frame = await board1x1Codec.getNextFrame();
      _board1x1Image = board1x1Frame.image;

      // Tahta 1x3 / 3x1 blok — 1x3.png
      final board1x3Data = await rootBundle.load('assets/buttons/1x3.png');
      final board1x3Codec = await ui.instantiateImageCodec(
        board1x3Data.buffer.asUint8List(),
      );
      final board1x3Frame = await board1x3Codec.getNextFrame();
      _board1x3Image = board1x3Frame.image;

      // Top ve kale görsellerini yükle
      final ballData = await rootBundle.load('assets/buttons/ball.png');
      final ballCodec = await ui.instantiateImageCodec(
        ballData.buffer.asUint8List(),
      );
      final ballFrame = await ballCodec.getNextFrame();
      _ballImage = ballFrame.image;

      final goalData = await rootBundle.load('assets/buttons/kale.png');
      final goalCodec = await ui.instantiateImageCodec(
        goalData.buffer.asUint8List(),
      );
      final goalFrame = await goalCodec.getNextFrame();
      _goalImage = goalFrame.image;
    } catch (_) {
      // Yüklenemezse düz renk kullanılır
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _calculateLayout();
  }

  void _calculateLayout() {
    const padding = 24.0;
    final availW = size.x - padding * 2;
    final availH = size.y - padding * 2;

    // Döndürülmüş görünüm: mantıksal genişlik (gridCols) ekranda dikey, mantıksal yükseklik (gridRows) yatay.
    // Bbox: gridRows*cellSize x (gridCols+0.6)*cellSize ekrana sığmalı.
    _cellSize = min(availW / level.gridRows, availH / (level.gridCols + 0.6));

    _gridOffsetX = 0;
    _gridOffsetY = 0;
    _logicalCenterX = level.gridCols * _cellSize / 2;
    _logicalCenterY = level.gridRows * _cellSize / 2;
  }

  /// Ekran koordinatını -90° dönüşüm sonrası mantıksal koordinata çevirir.
  Offset _screenToLogical(Offset screen) {
    final cx = size.x / 2;
    final cy = size.y / 2;
    // rotate(-90) inverse = rotate(90): (x,y) -> (-y, x)
    return Offset(
      cy - screen.dy + _logicalCenterX,
      screen.dx - cx + _logicalCenterY,
    );
  }

  /// Ekrandaki swipe velocity'den mantıksal yön (ekran -90° döndürülmüş).
  Direction _screenVelocityToDirection(double vx, double vy) {
    if (vx.abs() > vy.abs()) {
      return vx > 0 ? Direction.down : Direction.up;
    } else {
      return vy > 0 ? Direction.left : Direction.right;
    }
  }

  /// Ekran delta'sından swipe yönü (düşük hızda fallback).
  Direction? _screenDeltaToDirection(double dx, double dy) {
    if (dx.abs() < 25 && dy.abs() < 25) return null;
    if (dx.abs() > dy.abs()) {
      return dx > 0 ? Direction.down : Direction.up;
    } else {
      return dy > 0 ? Direction.left : Direction.right;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════

  @override
  void update(double dt) {
    super.update(dt);

    // Blok kayma animasyonu
    if (_animProgress < 1.0) {
      _animProgress += dt * _animSpeed;
      if (_animProgress >= 1.0) {
        _animProgress = 1.0;
        _animBlockId = null;
      }
    }

    // Gol efekti
    if (_showGoalEffect) {
      _goalEffectProgress += dt * 2.0;
      if (_goalEffectProgress >= 1.0) {
        _goalEffectProgress = 1.0;
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // RENDER
  // ═══════════════════════════════════════════════════════════

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // En arka plan: tribün görseli (tüm ekranı kaplar)
    _drawBackground(canvas);

    // Oyun alanı -90° döndürülmüş (kale üstte görünür)
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(-pi / 2);
    canvas.translate(-_logicalCenterX, -_logicalCenterY);
    _drawField(canvas);
    _drawExit(
      canvas,
    ); // fallback çizimi; gerçek kale görseli ekranda ayrı çizilir
    _drawGridCells(canvas);
    _drawBlocks(canvas);
    if (_showGoalEffect) {
      _drawGoalEffect(canvas);
    }
    canvas.restore();

    // Kale görseli ekran koordinatında üst orta, orijinal şekliyle (dönüşümsüz)
    if (_goalImage != null) {
      _drawGoalImageScreen(canvas);
    }
  }

  /// En arka plan: game_screen_bg.png (tüm ekranı kaplar, hafif karartılmış)
  void _drawBackground(Canvas canvas) {
    if (_gameBgImage != null) {
      final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
      final src = Rect.fromLTWH(
        0,
        0,
        _gameBgImage!.width.toDouble(),
        _gameBgImage!.height.toDouble(),
      );
      // Hafif karartma: ColorFilter ile siyah overlay (%15 opacity)
      final paint = Paint()
        ..colorFilter = ColorFilter.mode(
          Colors.black.withValues(alpha: 0.15),
          BlendMode.darken,
        );
      canvas.drawImageRect(_gameBgImage!, src, bgRect, paint);
    }
  }

  /// Saha arka planı + grid çizgileri + kenar çerçevesi.
  void _drawField(Canvas canvas) {
    final fieldRect = Rect.fromLTWH(
      _gridOffsetX - 5,
      _gridOffsetY - 5,
      _cellSize * level.gridCols + 10,
      _cellSize * level.gridRows + 10,
    );

    // Shadow: saha dikdörtgeninin arkasında gölge
    final shadowRect = fieldRect.shift(const Offset(0, 4));
    canvas.drawRect(
      shadowRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Saha arka planı: düz yeşil dikdörtgen (en arka plan game_screen_bg.png'de)
    canvas.drawRect(fieldRect, Paint()..color = AppColors.fieldGreen);

    // Kenar çerçevesi — sağ kenarda çıkış boşluğu bırak
    _drawBorderWithExitGap(canvas);
  }

  void _drawBorderWithExitGap(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final left = _gridOffsetX - 5;
    final top = _gridOffsetY - 5;
    final right = _gridOffsetX + _cellSize * level.gridCols + 5;
    final bottom = _gridOffsetY + _cellSize * level.gridRows + 5;

    final exitTop = _gridOffsetY + level.exitRow * _cellSize - 2;
    final exitBottom = exitTop + _cellSize + 4;

    // Sol kenar
    canvas.drawLine(Offset(left, top), Offset(left, bottom), paint);
    // Üst kenar
    canvas.drawLine(Offset(left, top), Offset(right, top), paint);
    // Alt kenar
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), paint);
    // Sağ kenar: çıkışın üstü
    canvas.drawLine(Offset(right, top), Offset(right, exitTop), paint);
    // Sağ kenar: çıkışın altı
    canvas.drawLine(Offset(right, exitBottom), Offset(right, bottom), paint);
  }

  /// Çıkış göstergesi (kale) — mantıksal alanda; gerçek kale görseli _drawGoalImageScreen ile ekranda.
  void _drawExit(Canvas canvas) {
    final exitLeft = _gridOffsetX + level.gridCols * _cellSize + 2;
    final exitTop = _gridOffsetY + level.exitRow * _cellSize + 2;
    final exitRect = Rect.fromLTWH(
      exitLeft,
      exitTop,
      _cellSize * 0.45,
      _cellSize - 4,
    );

    if (_goalImage == null) {
      // Fallback: eski kale çizimi
      canvas.drawRRect(
        RRect.fromRectAndRadius(exitRect, const Radius.circular(4)),
        Paint()..color = AppColors.goal.withValues(alpha: 0.6),
      );

      // Ağ deseni
      final netPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = 0.8;

      for (double x = exitRect.left + 5; x < exitRect.right; x += 5) {
        canvas.drawLine(
          Offset(x, exitRect.top + 2),
          Offset(x, exitRect.bottom - 2),
          netPaint,
        );
      }
      for (double y = exitRect.top + 5; y < exitRect.bottom; y += 5) {
        canvas.drawLine(
          Offset(exitRect.left + 2, y),
          Offset(exitRect.right - 2, y),
          netPaint,
        );
      }

      // Kale ikonu
      _drawIcon(canvas, exitRect.center, '🥅', _cellSize * 0.32);
    }
  }

  /// Kale görselini ekran koordinatında üst orta çizer. Ortadaki tek kare + sağ/sol yarım kare taşma (toplam 2 kare genişlik), en-boy oranı korunur.
  void _drawGoalImageScreen(Canvas canvas) {
    final gridTopY = size.y / 2 - (level.gridCols * _cellSize) / 2;
    const boxWidth = 2.0; // ortada 1 kare + her iki yanda yarım kare taşma
    final boxW = _cellSize * boxWidth;
    final boxH = _cellSize;
    final boxLeft = size.x / 2 - boxW / 2;
    final boxTop = gridTopY - _cellSize;
    final boxRect = Rect.fromLTWH(boxLeft, boxTop, boxW, boxH);

    final iw = _goalImage!.width.toDouble();
    final ih = _goalImage!.height.toDouble();
    final aspect = iw / ih;
    double w, h;
    if (aspect >= boxW / boxH) {
      w = boxW;
      h = boxW / aspect;
    } else {
      h = boxH;
      w = boxH * aspect;
    }
    final dst = Rect.fromCenter(center: boxRect.center, width: w, height: h);
    final src = Rect.fromLTWH(0, 0, iw, ih);
    canvas.drawImageRect(_goalImage!, src, dst, Paint());
  }

  /// Boş grid hücre arka planları — açık/koyu yeşil dama deseni (futbol sahası).
  void _drawGridCells(Canvas canvas) {
    for (int r = 0; r < level.gridRows; r++) {
      for (int c = 0; c < level.gridCols; c++) {
        final cellRect = Rect.fromLTWH(
          _gridOffsetX + c * _cellSize,
          _gridOffsetY + r * _cellSize,
          _cellSize,
          _cellSize,
        );

        // Dama deseni: (row + col) çift ise açık, tek ise koyu
        final isLight = (r + c) % 2 == 0;
        final grassImg = isLight ? _grassLight : _grassDark;

        if (grassImg != null) {
          final src = Rect.fromLTWH(
            0,
            0,
            grassImg.width.toDouble(),
            grassImg.height.toDouble(),
          );
          // Çim dokusunu 90° döndürerek çiz
          canvas.save();
          canvas.translate(
            cellRect.left + _cellSize / 2,
            cellRect.top + _cellSize / 2,
          );
          canvas.rotate(pi / 2);
          canvas.translate(-_cellSize / 2, -_cellSize / 2);
          canvas.drawImageRect(
            grassImg,
            src,
            Rect.fromLTWH(0, 0, _cellSize, _cellSize),
            Paint(),
          );
          canvas.restore();
        } else {
          // Fallback: düz renk dama deseni
          canvas.drawRect(
            cellRect,
            Paint()
              ..color = isLight
                  ? AppColors.fieldGreenLight.withValues(alpha: 0.15)
                  : AppColors.fieldGreen,
          );
        }
      }
    }
  }

  /// Tüm blokları çiz: önce engeller, sonra top (en üstte).
  void _drawBlocks(Canvas canvas) {
    // Engeller
    for (final block in _state.blocks) {
      if (block.isBall) continue;
      _drawObstacle(canvas, block);
    }
    // Top her zaman en üstte
    _drawBall(canvas, _state.ball);
  }

  // ─────────────────────────────────────────────────────────
  // TOP RENDER
  // ─────────────────────────────────────────────────────────

  void _drawBall(Canvas canvas, Block ball) {
    Offset center;

    if (_goalScored && _goalBallPos != null) {
      // Gol atıldı → top kale pozisyonunda sabit
      center = _goalBallPos!;
    } else if (_animBlockId == ball.id &&
        _animProgress < 1.0 &&
        _animFrom != null &&
        _animTo != null) {
      final t = Curves.easeOutCubic.transform(_animProgress);
      center = Offset.lerp(_animFrom!, _animTo!, t)!;
    } else {
      center = _blockCenter(ball);
    }

    final radius = _cellSize * 0.36;

    // Gölge
    canvas.drawCircle(
      center + const Offset(2, 3),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    if (_ballImage != null) {
      // Top görselini çiz
      final ballRect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 2,
      );
      final src = Rect.fromLTWH(
        0,
        0,
        _ballImage!.width.toDouble(),
        _ballImage!.height.toDouble(),
      );
      canvas.drawImageRect(_ballImage!, src, ballRect, Paint());
    } else {
      // Fallback: eski top çizimi
      final ballColor = ballSkinColor ?? Colors.white;
      canvas.drawCircle(center, radius, Paint()..color = ballColor);

      // Dış çizgi
      final outlineColor = ballSkinColor != null
          ? HSLColor.fromColor(ballColor).withLightness(0.2).toColor()
          : const Color(0xFF333333);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      // Pentagon deseni
      canvas.drawCircle(
        center,
        radius * 0.35,
        Paint()..color = outlineColor.withValues(alpha: 0.15),
      );

      // Işık efekti
      canvas.drawCircle(
        center - Offset(radius * 0.25, radius * 0.25),
        radius * 0.15,
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }

    // Seçili vurgusu
    if (_selectedBlockId == ball.id) {
      canvas.drawCircle(
        center,
        radius + 4,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // ENGEL BLOK RENDER
  // ─────────────────────────────────────────────────────────

  void _drawObstacle(Canvas canvas, Block block) {
    Offset center;
    Rect rect;

    if (_animBlockId == block.id &&
        _animProgress < 1.0 &&
        _animFrom != null &&
        _animTo != null) {
      final t = Curves.easeOutCubic.transform(_animProgress);
      center = Offset.lerp(_animFrom!, _animTo!, t)!;
      rect = Rect.fromCenter(
        center: center,
        width: block.width * _cellSize - 6,
        height: block.height * _cellSize - 6,
      );
    } else {
      rect = _blockRect(block);
      center = rect.center;
    }

    final color = _obstacleColor(block);

    // Tahta blok türleri:
    //  - 1x2 veya 2x1 → tabela.png
    //  - 1x1         → 1x1.png
    //  - 1x3 veya 3x1 → 1x3.png
    final isBoardBlock =
        (block.width == 2 && block.height == 1) ||
        (block.width == 1 && block.height == 2);
    final isBoard1x1 = block.width == 1 && block.height == 1;

    // Gölge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.shift(const Offset(2, 3)),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );

    if (isBoardBlock && _boardImage != null) {
      // Tahta blok (1x2 / 2x1): tabela görselini dikdörtgene sığdır
      final src = Rect.fromLTWH(
        0,
        0,
        _boardImage!.width.toDouble(),
        _boardImage!.height.toDouble(),
      );
      canvas.drawImageRect(_boardImage!, src, rect, Paint());
    } else if (isBoard1x1 && _board1x1Image != null) {
      // Tahta 1x1 blok: kare tahta görseli
      final src = Rect.fromLTWH(
        0,
        0,
        _board1x1Image!.width.toDouble(),
        _board1x1Image!.height.toDouble(),
      );
      canvas.drawImageRect(_board1x1Image!, src, rect, Paint());
    } else if (_board1x3Image != null &&
        ((block.width == 3 && block.height == 1) ||
            (block.width == 1 && block.height == 3))) {
      // Tahta 1x3 / 3x1 blok: uzun tahta görseli
      final src = Rect.fromLTWH(
        0,
        0,
        _board1x3Image!.width.toDouble(),
        _board1x3Image!.height.toDouble(),
      );
      canvas.drawImageRect(_board1x3Image!, src, rect, Paint());
    } else {
      // Gövde
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()..color = color,
      );

      // Parlak kenar
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Forma çizgisi (dekoratif)
      if (block.width >= 2 || block.height >= 2) {
        final stripePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.18)
          ..strokeWidth = 2;

        if (block.width >= block.height) {
          // Yatay blok → dikey çizgi
          canvas.drawLine(
            Offset(center.dx, rect.top + 6),
            Offset(center.dx, rect.bottom - 6),
            stripePaint,
          );
        } else {
          // Dikey blok → yatay çizgi
          canvas.drawLine(
            Offset(rect.left + 6, center.dy),
            Offset(rect.right - 6, center.dy),
            stripePaint,
          );
        }
      }

      // Forma ikonu (küçük bloklar için)
      final iconSize = min(block.width, block.height) * _cellSize * 0.28;
      _drawIcon(canvas, center, '🛡️', iconSize);
    }

    // Seçili vurgusu
    if (_selectedBlockId == block.id) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(10)),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // RENK & GEOMETRİ YARDIMCILARI
  // ─────────────────────────────────────────────────────────

  Rect _blockRect(Block block) {
    return Rect.fromLTWH(
      _gridOffsetX + block.col * _cellSize + 3,
      _gridOffsetY + block.row * _cellSize + 3,
      block.width * _cellSize - 6,
      block.height * _cellSize - 6,
    );
  }

  Offset _blockCenter(Block block) {
    return Offset(
      _gridOffsetX + block.col * _cellSize + block.width * _cellSize / 2,
      _gridOffsetY + block.row * _cellSize + block.height * _cellSize / 2,
    );
  }

  /// Blok boyutuna göre renk — kozmetik tema varsa onu kullan.
  Color _obstacleColor(Block block) {
    // Kozmetik tema varsa
    if (blockThemePrimary != null) {
      final w = block.width;
      final h = block.height;
      if (w == 1 && h == 1) return blockThemeSecondary ?? blockThemePrimary!;
      return blockThemePrimary!;
    }

    // Default renkler
    final w = block.width;
    final h = block.height;

    if (w == 1 && h == 1) return AppColors.defender; // mavi
    if (w > h) {
      return w >= 3 ? const Color(0xFFE65100) : const Color(0xFFFF8F00);
    }
    if (h > w) {
      return h >= 3 ? const Color(0xFF6A1B9A) : const Color(0xFF9C27B0);
    }
    return const Color(0xFFC62828);
  }

  // ─────────────────────────────────────────────────────────
  // GOL EFEKTİ
  // ─────────────────────────────────────────────────────────

  void _drawGoalEffect(Canvas canvas) {
    final center = _goalBallPos ?? _blockCenter(_state.ball);
    final t = Curves.easeOut.transform(_goalEffectProgress);

    // Genişleyen halkalar
    canvas.drawCircle(
      center,
      _cellSize * t * 2,
      Paint()
        ..color = AppColors.goal.withValues(alpha: 0.4 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(
      center,
      _cellSize * t * 1.2,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.3 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
  }

  void _drawIcon(Canvas canvas, Offset center, String emoji, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // ═══════════════════════════════════════════════════════════
  // SWIPE INPUT — BLOK SEÇ + KAYDIRMA YÖNÜ
  // ═══════════════════════════════════════════════════════════

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!_state.canMove || _animProgress < 1.0) return;

    _dragStartPos = event.canvasPosition;
    _lastDragPos = event.canvasPosition;

    // Ekran dokunma noktasını mantıksal koordinata çevir (döndürülmüş alan için)
    final touchPos = _screenToLogical(
      Offset(event.canvasPosition.x, event.canvasPosition.y),
    );
    _selectedBlockId = null;

    // Üstte çizilen bloklar önce kontrol edilsin (top en üstte) — ters sıra
    final blocksReversed = _state.blocks.toList().reversed;
    final touchExpand = (_cellSize * 0.15).clamp(12.0, 24.0);
    for (final block in blocksReversed) {
      if (_blockRect(block).inflate(touchExpand).contains(touchPos)) {
        _selectedBlockId = block.id;
        break;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    _lastDragPos = event.canvasEndPosition;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (_selectedBlockId == null || _dragStartPos == null) {
      _selectedBlockId = null;
      _dragStartPos = null;
      _lastDragPos = null;
      return;
    }

    if (!_state.canMove || _animProgress < 1.0) {
      _selectedBlockId = null;
      _dragStartPos = null;
      _lastDragPos = null;
      return;
    }

    final vx = event.velocity.x;
    final vy = event.velocity.y;
    Direction? dir;

    if (vx.abs() >= 45 || vy.abs() >= 45) {
      dir = _screenVelocityToDirection(vx, vy);
    } else if (_lastDragPos != null) {
      final dx = _lastDragPos!.x - _dragStartPos!.x;
      final dy = _lastDragPos!.y - _dragStartPos!.y;
      dir = _screenDeltaToDirection(dx, dy);
    }

    if (dir == null) {
      _selectedBlockId = null;
      _dragStartPos = null;
      _lastDragPos = null;
      return;
    }

    _executeMove(_selectedBlockId!, dir);
    _selectedBlockId = null;
    _dragStartPos = null;
    _lastDragPos = null;
  }

  // ═══════════════════════════════════════════════════════════
  // HAMLE UYGULA — SLIDE UNTIL HIT
  // ═══════════════════════════════════════════════════════════

  void _executeMove(String blockId, Direction dir) {
    // Kaydırma sonucunu hesapla
    final result = PuzzleEngine.slideBlock(
      currentBlocks: _state.blocks,
      blockId: blockId,
      direction: dir,
      gridRows: level.gridRows,
      gridCols: level.gridCols,
      exitRow: level.exitRow,
    );

    // Hareket yoksa hamle sayılmaz
    if (result.distance == 0) return;

    // Eski blok konumu (animasyon için)
    final oldBlock = _state.blocks.firstWhere((b) => b.id == blockId);
    final newBlock = result.blocks.firstWhere((b) => b.id == blockId);

    // Animasyon başlat
    _animBlockId = blockId;
    _animFrom = _blockCenter(oldBlock);

    if (result.solved && blockId == 'ball') {
      // Top çıkışa doğru kayma animasyonu
      _animTo = Offset(
        _gridOffsetX + level.gridCols * _cellSize + _cellSize * 0.3,
        _gridOffsetY + level.exitRow * _cellSize + _cellSize / 2,
      );
    } else {
      _animTo = _blockCenter(newBlock);
    }
    _animProgress = 0.0;

    // Hamle kaydı
    final moveRecord = MoveRecord(
      blockId: blockId,
      direction: dir,
      distance: result.distance,
    );

    final newMoves = _state.movesUsed + 1;

    // State güncelle
    _state = _state.copyWith(
      blocks: result.blocks,
      movesUsed: newMoves,
      isCompleted: result.solved,
      isFailed: !result.solved && newMoves >= level.maxMoves,
      moveHistory: [..._state.moveHistory, moveRecord],
    );

    onMove(moveRecord);

    if (result.solved) {
      // Top kaleye girdi — kale pozisyonunu kaydet, top burada sabit kalacak
      _goalScored = true;
      _goalBallPos = Offset(
        _gridOffsetX + level.gridCols * _cellSize + _cellSize * 0.22,
        _gridOffsetY + level.exitRow * _cellSize + _cellSize / 2,
      );
      _showGoalEffect = true;
      _goalEffectProgress = 0.0;
      Future.delayed(const Duration(milliseconds: 900), () => onGoal());
    } else if (_state.isFailed) {
      Future.delayed(const Duration(milliseconds: 400), () => onFail());
    }
  }

  // ═══════════════════════════════════════════════════════════
  // OYUN SIFIRLA
  // ═══════════════════════════════════════════════════════════

  void resetGame() {
    _state = PuzzleGameState(
      level: level,
      blocks: List<Block>.from(level.initialBlocks),
    );
    _animProgress = 1.0;
    _animBlockId = null;
    _animFrom = null;
    _animTo = null;
    _showGoalEffect = false;
    _goalEffectProgress = 0.0;
    _goalScored = false;
    _goalBallPos = null;
    _selectedBlockId = null;
    _dragStartPos = null;
    _lastDragPos = null;
  }

  /// Ekstra hamle ekle (power-up).
  void addExtraMove() {
    if (_state.isCompleted || _state.isFailed) return;
    // maxMoves'u artır → yeni level kopyası
    final newLevel = PuzzleLevel(
      levelNumber: level.levelNumber,
      season: level.season,
      gridRows: level.gridRows,
      gridCols: level.gridCols,
      maxMoves: _state.level.maxMoves + 1,
      optimalMoves: level.optimalMoves,
      initialBlocks: level.initialBlocks,
      exitRow: level.exitRow,
      exitCol: level.exitCol,
      difficultyTier: level.difficultyTier,
    );
    _state = PuzzleGameState(
      level: newLevel,
      blocks: _state.blocks,
      movesUsed: _state.movesUsed,
      isCompleted: _state.isCompleted,
      isFailed: false,
      moveHistory: _state.moveHistory,
    );
  }
}
