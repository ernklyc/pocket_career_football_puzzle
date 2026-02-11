import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/domain/entities/puzzle.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/shadowed_asset.dart';

/// Level numarasına göre zorluk etiketi.
String _difficultyLabel(int levelNumber) {
  if (levelNumber <= 25) return 'Kolay';
  if (levelNumber <= 50) return 'Orta';
  return 'Zor';
}

/// Skor özeti ekranı — GameScreen/HomePage tasarım dili: background, paper kart, win/lose/draw asset, gölgeler.
class ScoreSummaryScreen extends ConsumerWidget {
  const ScoreSummaryScreen({super.key});

  static const _cardShadow = [
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastSessionResultProvider);

    if (result == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/game/main');
      });
      return const SizedBox.shrink();
    }

    final matchResult = result.matchResult;
    final matchPoints = result.matchPoints;

    // Sadece win/draw/lose.png ve puan metni (Mağlubiyet/Galibiyet/Beraberlik yok)
    final String resultAssetPath;
    final String pointsText;

    if (!result.isCompleted) {
      resultAssetPath = 'assets/buttons/lose.png';
      pointsText = '0 Puan';
    } else {
      switch (matchResult) {
        case MatchResult.win:
          resultAssetPath = 'assets/buttons/win.png';
          pointsText = '$matchPoints Puan';
          break;
        case MatchResult.draw:
          resultAssetPath = 'assets/buttons/draw.png';
          pointsText = '$matchPoints Puan';
          break;
        case MatchResult.loss:
          resultAssetPath = 'assets/buttons/lose.png';
          pointsText = '$matchPoints Puan';
          break;
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/league/5.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/buttons/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: HomeLayout.contentPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Ana kart — paper (win/lose/draw PNG + büyük puan yazısı, LEVEL yok)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/buttons/paper.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadowedAsset(
                          imagePath: resultAssetPath,
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pointsText,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.parchmentText,
                            fontSize: 28,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // İstatistikler — paper (parşömen kenarlarından içeride)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(36, 32, 36, 28),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/buttons/paper.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _cardShadow,
                      ),
                      child: Column(
                        children: [
                          _StatRow(
                            label: context.tr('results_score'),
                            value: '${result.score}',
                            valueColor: AppColors.accentDark,
                          ),
                          const _PaperDivider(),
                          _StatRow(
                            label: 'Hamle',
                            value: '${result.movesUsed} / ${result.movesMax}',
                          ),
                          const _PaperDivider(),
                          _StatRow(
                            label: 'Level',
                            value: '${result.levelNumber}',
                          ),
                          const _PaperDivider(),
                          _StatRow(
                            label: 'Zorluk',
                            value: _difficultyLabel(result.levelNumber),
                          ),
                          const _PaperDivider(),
                          _PuanHamleLegend(
                            optimalMoves: result.optimalMoves,
                            movesMax: result.movesMax,
                          ),
                          if (result.coinsEarned > 0) ...[
                            const _PaperDivider(),
                            _StatRow(
                              label: context.tr('results_coins_earned'),
                              value: '+${result.coinsEarned}',
                              valueColor: AppColors.coin,
                              icon: Icons.monetization_on,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Butonlar yan yana: sol Çıkış, sağ Tekrar Dene / Sonraki Level
                  Row(
                    children: [
                      Expanded(
                        child: _AssetTextButton(
                          imagePath: 'assets/buttons/red_button.png',
                          label: 'Çıkış',
                          textColor: Colors.white,
                          onTap: () => context.go('/game/main'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: result.isCompleted
                            ? _AssetTextButton(
                                imagePath: 'assets/buttons/play_button_v2.png',
                                label: context.tr('results_next'),
                                textColor: AppColors.fieldGreenDark,
                                onTap: () {
                                  const maxLevel = 100;
                                  if (result.levelNumber >= maxLevel) {
                                    context.go('/game/main');
                                    return;
                                  }
                                  final nextLevel = result.levelNumber + 1;
                                  if (result.levelNumber % 5 == 0) {
                                    ref.read(nextLevelAfterPaywallProvider.notifier).state = nextLevel;
                                    context.go('/paywall/coins');
                                  } else {
                                    context.go('/play', extra: {'season': 1, 'level': nextLevel});
                                  }
                                },
                              )
                            : _AssetTextButton(
                                imagePath: 'assets/buttons/play_button_v2.png',
                                label: 'Tekrar Dene',
                                textColor: AppColors.fieldGreenDark,
                                onTap: () => context.go('/play', extra: {'season': 1, 'level': result.levelNumber}),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asset arka planlı buton (home OYNA/orange stili).
class _AssetTextButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final Color textColor;
  final VoidCallback onTap;

  const _AssetTextButton({
    required this.imagePath,
    required this.label,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.fill,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(color: Colors.white, offset: Offset(1, 1), blurRadius: 0),
                Shadow(color: Colors.white70, offset: Offset(0, 1), blurRadius: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3 / 1 / 0 puan için hamle aralıklarını gösterir (max 2 hamle, max 6 hamle, min 7 hamle).
class _PuanHamleLegend extends StatelessWidget {
  final int optimalMoves;
  final int movesMax;

  const _PuanHamleLegend({
    required this.optimalMoves,
    required this.movesMax,
  });

  @override
  Widget build(BuildContext context) {
    final drawThreshold = optimalMoves +
        ((movesMax - optimalMoves) * 0.5).ceil().clamp(0, movesMax);
    final minLossMoves = drawThreshold + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _PuanHamleChip(
              puan: 3,
              sub: 'max $optimalMoves hamle',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PuanHamleChip(
              puan: 1,
              sub: 'max $drawThreshold hamle',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _PuanHamleChip(
              puan: 0,
              sub: 'min $minLossMoves hamle',
            ),
          ),
        ],
      ),
    );
  }
}

class _PuanHamleChip extends StatelessWidget {
  final int puan;
  final String sub;

  const _PuanHamleChip({required this.puan, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$puan Puan',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.parchmentText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.parchmentTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PaperDivider extends StatelessWidget {
  const _PaperDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
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

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: AppColors.parchmentTextSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: valueColor ?? AppColors.parchmentText, size: 16),
                  const SizedBox(width: 4),
                ],
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: valueColor ?? AppColors.parchmentText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
