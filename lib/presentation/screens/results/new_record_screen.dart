import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/game_button.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/shadowed_asset.dart';

/// Yeni rekor ekranı — GameScreen/HomePage tasarım dili: background, paper kart, trophy asset, gölgeler.
class NewRecordScreen extends ConsumerWidget {
  const NewRecordScreen({super.key});

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

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/buttons/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: HomeLayout.contentPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Paper kart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/buttons/paper.png'),
                        fit: BoxFit.fill,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _cardShadow,
                    ),
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: ShadowedAsset(
                            imagePath: 'assets/buttons/trophy.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('results_new_record'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.gold,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('results_congratulations'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.parchmentTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Skor kutusu — paper üzerinde ince altın çerçeve
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                context.tr('results_score'),
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.parchmentTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${result.score}',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.gold,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(1, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (result.coinsEarned > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.monetization_on, color: AppColors.coin, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                '+${result.coinsEarned}',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.coin,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Spacer(),

                  GameButton(
                    text: context.tr('results_next'),
                    onPressed: () {
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
                    width: double.infinity,
                    backgroundColor: AppColors.gold,
                    textColor: AppColors.background,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 12),
                  GameButton(
                    text: 'Ana Ekrana Dön',
                    onPressed: () => context.go('/game/main'),
                    width: double.infinity,
                    isOutlined: true,
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 12),
                  GameButton(
                    text: context.tr('results_menu'),
                    onPressed: () => context.go('/game/main'),
                    width: double.infinity,
                    isOutlined: true,
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
