import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/data/repositories/level_repository.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/services/lives_service.dart';
import 'package:pocket_career_football_puzzle/services/progress_service.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/pressable_scale.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/shadowed_asset.dart';

/// Yeni ana ekran — AppBar(profil, enerji, koleksiyon) + Orta(seviye bilgileri) + Alt(sıralama, oyna, mağaza)
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(livesProvider.notifier).refresh();
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  static String _formatRemaining(Duration? d) {
    if (d == null || d <= Duration.zero) return '';
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    if (min >= 60) return '${d.inHours}sa ${d.inMinutes % 60}dk';
    return '${min}dk ${sec}sn';
  }

  /// Ekran görüntüsündeki gibi MM:SS (örn. 09:31)
  static String _formatRemainingMMSS(Duration? d) {
    if (d == null || d <= Duration.zero) return '00:00';
    final totalSec = d.inSeconds;
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(activeCareerProvider);
    final progress = ref.watch(progressProvider);
    final lives = ref.watch(livesProvider);
    final isPremium = ref.watch(entitlementProvider);
    final levelRepo = ref.read(levelRepositoryProvider);
    final totalLevels = levelRepo.levelCount > 0
        ? levelRepo.levelCount
        : LevelRepository.totalLevels;
    final hasLives = isPremium || lives > 0;
    final remaining = ref.read(livesServiceProvider).timeUntilNextRegen;
    final remainingStr = _formatRemaining(remaining);

    final currentLevel = progress.currentLevel;
    final currentKey = '$currentLevel';
    final currentLevelProgress = progress.levels[currentKey];
    final isCurrentCompleted = currentLevelProgress?.completed ?? false;
    final puzzleLevel = levelRepo.getLevel(currentLevel);

    final team = career != null
        ? AppConfig.availableTeams.firstWhere(
            (t) => t.id == career.teamId,
            orElse: () => AppConfig.availableTeams.first,
          )
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ═══════════════════ BACKGROUND IMAGE (sadece ana sayfa) ═══════════════════
          Positioned.fill(
            child: Image.asset(
              'assets/image/stadyum_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // ═══════════════════ APP BAR ═══════════════════
              Container(
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
                    padding: HomeLayout.barPadding,
                    child: Row(
                      children: [
                        // Profil avatarı (ufak shadow)
                        PressableScale(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: team != null
                                  ? Color(team.primaryColor)
                                  : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: team != null && team.logoAssetPath != null
                                  ? Image.asset(
                                      team.logoAssetPath!,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Text(
                                        team?.logoEmoji ?? '⚽',
                                        style: TextStyle(
                                          fontFamily: AppTheme.bodyFontFamily,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // Enerji + Timer — Row(enerji ikonu, Column(enerji sayısı, kalan süre))
                        PressableScale(
                          onTap: () {
                            // Gelecekte enerji satın alma ekranı
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: Center(
                                    child: Image.asset(
                                      'assets/buttons/energy.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      isPremium
                                          ? '∞'
                                          : '$lives/${LivesService.maxLives}',
                                      style: TextStyle(
                                        fontFamily: AppTheme.titleFontFamily,
                                        color: hasLives
                                            ? Colors.white
                                            : AppColors.error,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        height: 1.0,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.7,
                                            ),
                                            offset: const Offset(2, 2),
                                            blurRadius: 4,
                                          ),
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                            offset: const Offset(0, 0),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isPremium &&
                                        lives < LivesService.maxLives &&
                                        remaining != null &&
                                        remaining > Duration.zero)
                                      Text(
                                        _formatRemainingMMSS(remaining),
                                        style: TextStyle(
                                          fontFamily: AppTheme.titleFontFamily,
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.7,
                                              ),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.5,
                                              ),
                                              offset: const Offset(0, 0),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Spacer(),

                        // Koleksiyon
                        PressableScale(
                          onTap: () => context.push('/collection'),
                          child: ShadowedAsset(
                            imagePath: 'assets/buttons/collection.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Ödüller
                        PressableScale(
                          onTap: () => context.push('/rewards'),
                          child: ShadowedAsset(
                            imagePath: 'assets/buttons/trophy.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Günlük Giriş Ödülleri
                        PressableScale(
                          onTap: () {
                            // TODO: Günlük giriş ödülleri popup'ı açılacak
                          },
                          child: ShadowedAsset(
                            imagePath: 'assets/image/gift.png',
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ═══════════════════ MIDDLE CONTENT ═══════════════════
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: HomeLayout.contentPadding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 32,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _CurrentLevelCard(
                              levelNumber: currentLevel,
                              puzzleLevel: puzzleLevel,
                              levelProgress: currentLevelProgress,
                              isCompleted: isCurrentCompleted,
                              totalLevels: totalLevels,
                            ),
                            const SizedBox(height: 12),
                            // LEVELS — tabela, boyut texte göre küçük
                            PressableScale(
                              onTap: () => _showAllSectionsBoard(
                                context,
                                progress: progress,
                                totalLevels: totalLevels,
                                currentLevel: currentLevel,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/buttons/orange_button.png',
                                      fit: BoxFit.fill,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 26,
                                      vertical: 14,
                                    ),
                                    child: Text(
                                      'SEE ALL LEVELS',
                                      style: TextStyle(
                                        fontFamily: AppTheme.titleFontFamily,
                                        color: const Color(0xFFFFFBF0),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0xFF3E2723),
                                            offset: Offset(2, 2),
                                            blurRadius: 2,
                                          ),
                                          Shadow(
                                            color: AppColors.parchmentText,
                                            offset: Offset(1, 1),
                                            blurRadius: 0,
                                          ),
                                          Shadow(
                                            color: Color(0x40000000),
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ═══════════════════ BOTTOM BAR ═══════════════════
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/buttons/bottom_nav_bar.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, -4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: HomeLayout.barPadding,
                    child: Row(
                      children: [
                        // Sıralama
                        Expanded(
                          child: _BottomBarImageButton(
                            imagePath: 'assets/buttons/leaderboard.png',
                            label: 'Sıralama',
                            onTap: () => context.push('/leaderboard'),
                          ),
                        ),
                        // Oyna butonu (parşömen stil)
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: PressableScale(
                              onTap: () {
                                if (!hasLives && !isCurrentCompleted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Canın kalmadı. ${remainingStr.isNotEmpty ? '$remainingStr sonra dolacak.' : 'Kısa süre içinde dolacak.'}',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                                context.go(
                                  '/play',
                                  extra: {
                                    'season': career?.currentSeason ?? 1,
                                    'level': currentLevel,
                                    'isReplay': isCurrentCompleted,
                                  },
                                );
                              },
                              child: Container(
                                height: 60,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                      'assets/buttons/play_button_v2.png',
                                    ),
                                    fit: BoxFit.fill,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      child: Center(
                                        child: Text(
                                          isCurrentCompleted
                                              ? 'TEKRAR'
                                              : 'OYNA',
                                          style: TextStyle(
                                            fontFamily:
                                                AppTheme.titleFontFamily,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.fieldGreenDark,
                                            letterSpacing: 0.5,
                                            height: 1.0,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.white,
                                                offset: Offset(1, 1),
                                                blurRadius: 0,
                                              ),
                                              Shadow(
                                                color: Colors.white70,
                                                offset: Offset(0, 1),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (!isPremium && !isCurrentCompleted) ...[
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        height: 24,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                '-1',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppTheme.titleFontFamily,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColors.fieldGreenDark,
                                                  height: 1.0,
                                                  shadows: const [
                                                    Shadow(
                                                      color: Colors.white,
                                                      offset: Offset(1, 1),
                                                      blurRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/buttons/energy.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Mağaza
                        Expanded(
                          child: _BottomBarImageButton(
                            imagePath: 'assets/buttons/shop.png',
                            label: 'Mağaza',
                            onTap: () => context.push('/shop'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Alt bar: resim + etiket (Sıralama / Mağaza)
class _BottomBarImageButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _BottomBarImageButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                label == 'Sıralama' ? Icons.leaderboard : Icons.shop,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.titleFontFamily,
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              shadows: const [
                Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tüm bölümler popup — paper.png üzerinde grid + üstte mevcut/toplam
void _showAllSectionsBoard(
  BuildContext context, {
  required ProgressData progress,
  required int totalLevels,
  required int currentLevel,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: HomeLayout.screenHorizontalPadding,
        vertical: 40,
      ),
      child: _AllSectionsBoard(
        progress: progress,
        totalLevels: totalLevels,
        currentLevel: currentLevel,
      ),
    ),
  );
}

class _AllSectionsBoard extends StatefulWidget {
  final ProgressData progress;
  final int totalLevels;
  final int currentLevel;

  const _AllSectionsBoard({
    required this.progress,
    required this.totalLevels,
    required this.currentLevel,
  });

  @override
  State<_AllSectionsBoard> createState() => _AllSectionsBoardState();
}

class _AllSectionsBoardState extends State<_AllSectionsBoard> {
  final GlobalKey _currentLevelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentLevelKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.4,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 5;
    final count = widget.totalLevels.clamp(1, 999);
    final currentLevel = widget.currentLevel;
    final progress = widget.progress;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
            image: AssetImage('assets/buttons/paper.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 8),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Level $currentLevel / ${widget.totalLevels}',
                  style: TextStyle(
                    fontFamily: AppTheme.titleFontFamily,
                    color: AppColors.parchmentText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: count,
                    itemBuilder: (context, index) {
                      final levelNum = index + 1;
                      final key = '$levelNum';
                      final lp = progress.levels[key];
                      final completed = lp?.completed ?? false;
                      final points = lp?.matchPoints ?? 0;
                      final pointsStr = completed
                          ? (points >= 3
                                ? '3p'
                                : points >= 1
                                ? '1p'
                                : '0p')
                          : '—';
                      final cell = Container(
                        decoration: BoxDecoration(
                          color: completed
                              ? (points >= 3
                                    ? AppColors.success.withValues(alpha: 0.35)
                                    : points >= 1
                                    ? AppColors.gold.withValues(alpha: 0.35)
                                    : AppColors.error.withValues(alpha: 0.35))
                              : AppColors.parchmentFill.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.parchmentBorder.withValues(
                              alpha: 0.6,
                            ),
                            width: 1,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$levelNum',
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFontFamily,
                                  color: AppColors.parchmentText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pointsStr,
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFontFamily,
                                  color: AppColors.parchmentText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (index == currentLevel - 1) {
                        return KeyedSubtree(key: _currentLevelKey, child: cell);
                      }
                      return cell;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Current Level Card
// ══════════════════════════════════════════════════════════════
class _CurrentLevelCard extends StatelessWidget {
  final int levelNumber;
  final PuzzleLevel? puzzleLevel;
  final LevelProgress? levelProgress;
  final bool isCompleted;
  final int totalLevels;

  const _CurrentLevelCard({
    required this.levelNumber,
    required this.puzzleLevel,
    required this.levelProgress,
    required this.isCompleted,
    required this.totalLevels,
  });

  @override
  Widget build(BuildContext context) {
    final difficulty = puzzleLevel?.difficultyLabel ?? '—';
    final optimalMoves = puzzleLevel?.optimalMoves ?? 0;
    final maxMoves = puzzleLevel?.maxMoves ?? 0;
    final bestScore = levelProgress?.bestScore ?? 0;
    final bestMoves = levelProgress?.bestMoves ?? 0;
    final matchPoints = levelProgress?.matchPoints ?? -1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            HomeLayout.screenHorizontalPadding,
            24, // üst biraz boşluk
            HomeLayout.screenHorizontalPadding,
            36, // alt daha fazla boşluk
          ),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/image/text_bg.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tek blok: Level + zorluk + istatistikler/puan
              Text(
                isCompleted ? 'Level $levelNumber ✓' : 'Level $levelNumber',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$levelNumber / $totalLevels',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentTextSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              _DifficultyBadge(label: difficulty, onParchment: true),
              const SizedBox(height: 12),

              if (isCompleted) ...[
                _PaperDivider(),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.star,
                  label: 'En İyi Skor',
                  value: '$bestScore',
                  valueColor: AppColors.accentDark,
                  onParchment: true,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.trending_down,
                  label: 'En İyi Hamle',
                  value: '$bestMoves',
                  valueColor: AppColors.info,
                  onParchment: true,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.sports_soccer,
                  label: 'Maç Sonucu',
                  value: matchPoints >= 3
                      ? 'Galibiyet (3P)'
                      : matchPoints >= 1
                      ? 'Beraberlik (1P)'
                      : 'Mağlubiyet (0P)',
                  valueColor: matchPoints >= 3
                      ? AppColors.success
                      : matchPoints >= 1
                      ? AppColors.gold
                      : AppColors.error,
                  onParchment: true,
                ),
              ],

              if (!isCompleted && puzzleLevel != null) ...[
                _PaperDivider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PuanChip(
                      label: '3 Puan',
                      moveInfo: 'max $optimalMoves hamle',
                    ),
                    _PuanChip(
                      label: '1 Puan',
                      moveInfo:
                          'max ${optimalMoves + ((maxMoves - optimalMoves) * 0.5).ceil()} hamle',
                    ),
                    _PuanChip(
                      label: '0 Puan',
                      moveInfo:
                          'min ${optimalMoves + ((maxMoves - optimalMoves) * 0.5).ceil() + 1} hamle',
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════

/// Kağıt üzerinde bölüm ayırıcı (tema uyumlu)
class _PaperDivider extends StatelessWidget {
  const _PaperDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.parchmentBorder.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String label;
  final bool onParchment;

  const _DifficultyBadge({required this.label, this.onParchment = false});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;

    switch (label) {
      case 'Öğretici':
        bgColor = AppColors.info;
      case 'Kolay':
        bgColor = AppColors.success;
      case 'Orta':
        bgColor = AppColors.gold;
      case 'Zor':
        bgColor = AppColors.error;
      case 'Boss':
        bgColor = const Color(0xFF9C27B0);
      default:
        bgColor = AppColors.textHint;
    }

    if (onParchment) {
      // Kağıt üzerinde: tahta arka plan — tabela.png (Öğretici, Kolay, Orta, Zor, Boss)
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage('assets/buttons/tabela.png'),
            fit: BoxFit.fill,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.titleFontFamily,
              color: const Color(0xFFFFFBF0),
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              shadows: const [
                Shadow(
                  color: Color(0xFF3E2723),
                  offset: Offset(2, 2),
                  blurRadius: 2,
                ),
                Shadow(
                  color: AppColors.parchmentText,
                  offset: Offset(1, 1),
                  blurRadius: 0,
                ),
                Shadow(
                  color: Color(0x40000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Kağıt dışında: renkli tier stili
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bgColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.bodyFontFamily,
          color: bgColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Kompakt puan + hamle bilgisi (kağıt teması)
class _PuanChip extends StatelessWidget {
  final String label;
  final String moveInfo;

  const _PuanChip({required this.label, required this.moveInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.titleFontFamily,
            color: AppColors.parchmentText,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          moveInfo,
          style: TextStyle(
            fontFamily: AppTheme.bodyFontFamily,
            color: AppColors.parchmentTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool onParchment;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onParchment = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = onParchment
        ? AppColors.parchmentTextSecondary
        : AppColors.textSecondary;
    final valueDefaultColor = onParchment
        ? AppColors.parchmentText
        : AppColors.textPrimary;
    final iconColor = onParchment
        ? AppColors.parchmentTextSecondary
        : AppColors.textHint;
    final effectiveValueColor = onParchment
        ? AppColors.parchmentText
        : (valueColor ?? valueDefaultColor);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.bodyFontFamily,
            color: labelColor,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTheme.bodyFontFamily,
            color: effectiveValueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
