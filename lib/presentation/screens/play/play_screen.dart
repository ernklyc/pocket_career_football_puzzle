import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/game/football_puzzle_game.dart';
import 'package:pocket_career_football_puzzle/game/level_generator.dart';
import 'package:pocket_career_football_puzzle/domain/entities/active_cosmetics.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/services/session_service.dart';

/// Oyun ekranı — Move the Block bulmaca. — Move the Block bulmaca.
class PlayScreen extends ConsumerStatefulWidget {
  final int season;
  final int level;
  final bool isReplay;

  const PlayScreen({
    super.key,
    required this.season,
    required this.level,
    this.isReplay = false,
  });

  @override
  ConsumerState<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends ConsumerState<PlayScreen> {
  late FootballPuzzleGame _game;
  late PuzzleLevel _level;
  bool _isGoal = false;
  int _movesUsed = 0;

  @override
  void initState() {
    super.initState();

    // Can harca (premium veya tekrar oynama ise can harcama)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isPremium = ref.read(entitlementProvider);
      if (!isPremium && !widget.isReplay) {
        final ok = await ref.read(livesProvider.notifier).spendLife();
        if (!mounted) return;
        if (!ok) {
          final livesService = ref.read(livesServiceProvider);
          final remaining = livesService.timeUntilNextRegen;
          final waitText = remaining != null && remaining > Duration.zero
              ? '${remaining.inMinutes} dk ${remaining.inSeconds % 60} sn sonra dolacak.'
              : 'Kısa süre içinde dolacak.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Canın kalmadı. $waitText'),
              duration: const Duration(seconds: 3),
            ),
          );
          context.go('/game/main');
          return;
        }
      }
    });

    // Sabit level deposundan yükle. Bulunamazsa fallback üret.
    final repo = ref.read(levelRepositoryProvider);
    final storedLevel = repo.getLevel(widget.level);
    _level = storedLevel ??
        LevelGenerator.generate(levelNumber: widget.level);

    // Kozmetik ayarları
    final cosmetics = ref.read(activeCosmeticsProvider);
    Color? ballColor;
    Color? blockPrimary;
    Color? blockSecondary;
    if (cosmetics.activeBallSkin != null) {
      final skin = CosmeticDefinitions.ballSkins[cosmetics.activeBallSkin!];
      if (skin != null) ballColor = Color(skin.color);
    }
    if (cosmetics.activeBlockTheme != null) {
      final theme = CosmeticDefinitions.blockThemes[cosmetics.activeBlockTheme!];
      if (theme != null) {
        blockPrimary = Color(theme.primaryColor);
        blockSecondary = Color(theme.secondaryColor);
      }
    }

    _game = FootballPuzzleGame(
      level: _level,
      onMove: _onMove,
      onGoal: _onGoal,
      onFail: _onFail,
      ballSkinColor: ballColor,
      blockThemePrimary: blockPrimary,
      blockThemeSecondary: blockSecondary,
    );

    ref.read(sessionServiceProvider).startSession(_level);
  }

  void _onMove(MoveRecord move) {
    if (!mounted) return;
    setState(() {
      _movesUsed = _game.gameState.movesUsed;
    });
  }

  void _onGoal() {
    if (!mounted) return;
    setState(() => _isGoal = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _endGame(true);
    });
  }

  void _onFail() {
    if (!mounted) return;
    _endGame(false);
  }

  void _endGame(bool completed) {
    final storage = ref.read(localStorageProvider);
    final levelKey = '${widget.level}';
    final score = SessionService.calculateScore(
      levelNumber: widget.level,
      movesUsed: _movesUsed,
      maxMoves: _level.maxMoves,
    );
    final isNewRecord = storage.isNewRecord(levelKey, score);

    final result = ref.read(sessionServiceProvider).endSession(
          score: score,
          movesUsed: _movesUsed,
          isCompleted: completed,
          isNewRecord: isNewRecord,
        );

    if (completed) {
      ref.read(progressProvider.notifier).completeLevel(
            level: widget.level,
            score: score,
            movesUsed: _movesUsed,
            optimalMoves: _level.optimalMoves,
            maxMoves: _level.maxMoves,
          );

      storage.setHighScore(levelKey, score);

      ref.read(careerServiceProvider).onLevelCompleted(
            score: score,
            isGoal: true,
          );
      ref.read(careersProvider.notifier).refresh();
    }

    ref.read(lastSessionResultProvider.notifier).state = result;
    context.go('/results/score');
  }

  void _resetLevel() {
    _game.resetGame();
    setState(() {
      _movesUsed = 0;
      _isGoal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final movesRemaining = _level.maxMoves - _movesUsed;
    final isLowMoves = movesRemaining <= 2 && !_isGoal;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Flame oyun alanı (gölgeli panel)
          Positioned.fill(
            top: 64,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: GameWidget(game: _game),
            ),
          ),

          // Üst bilgi çubuğu (asset tam kaplasın; home gibi Container dışta, SafeArea içte)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/buttons/appbar.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                    // Level bilgisi (parşömen, pause butonu yüksekliği 44)
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/buttons/paper.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Level ${widget.level}',
                        style: TextStyle(
                          fontFamily: AppTheme.titleFontFamily,
                          color: AppColors.parchmentText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                      const Spacer(),

                      // Hamle sayacı (parşömen, pause butonu yüksekliği 44)
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$movesRemaining Hamle',
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: isLowMoves ? AppColors.error : AppColors.parchmentText,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Replay (pause'un solunda)
                      _MiniButton(
                        imagePath: 'assets/buttons/rety.png',
                        onTap: _isGoal ? null : _resetLevel,
                        child: const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 8),

                      // Duraklat
                      _MiniButton(
                        imagePath: 'assets/buttons/pause.png',
                        onTap: () => context.push('/pause'),
                        child: const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // GOL efekti overlay
          if (_isGoal)
            _GoalOverlay(),
        ],
      ),
    );
  }
}

class _GoalOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.goal.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.goal.withValues(alpha: 0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('play_goal'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// mini-button.png veya özel görsel, basınca küçülen fiziksel buton hissi.
class _MiniButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  /// Verilirse bu görsel kullanılır (örn. pause.png, rety.png); yoksa mini-button.png.
  final String? imagePath;

  const _MiniButton({
    required this.child,
    this.onTap,
    this.imagePath,
  });

  @override
  State<_MiniButton> createState() => _MiniButtonState();
}

class _MiniButtonState extends State<_MiniButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      scale: _pressed ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              widget.imagePath ?? 'assets/buttons/mini-button.png',
              fit: BoxFit.fill,
            ),
            Center(child: widget.child),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: Opacity(
        opacity: widget.onTap != null ? 1.0 : 0.5,
        child: content,
      ),
    );
  }
}
