import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/config/progression_schema.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/shadowed_asset.dart';

/// Yeni rekor ekranı — GameScreen/HomePage tasarım dili: background, paper kart, trophy asset, gölgeler.
class NewRecordScreen extends ConsumerWidget {
  const NewRecordScreen({super.key});

  static const _cardShadow = [
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 2),
      blurRadius: 6,
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
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
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
                            fontFamily: AppTheme.titleFontFamily,
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
                            fontFamily: AppTheme.titleFontFamily,
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
                                  fontFamily: AppTheme.titleFontFamily,
                                  color: AppColors.parchmentTextSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${result.score}',
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFontFamily,
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
                      ],
                    ),
                  ),

                  const Spacer(),

                  _AssetTextButton(
                    imagePath: 'assets/buttons/play_button_v2.png',
                    label: context.tr('results_next'),
                    textColor: AppColors.fieldGreenDark,
                    onTap: () {
                      final maxLevel = ProgressionSchema.levelCount;
                      if (result.levelNumber >= maxLevel) {
                        context.go('/game/main');
                        return;
                      }
                      final nextLevel = result.levelNumber + 1;
                      context.go('/play', extra: {'season': 1, 'level': nextLevel});
                    },
                  ),
                  const SizedBox(height: 12),
                  _AssetTextButton(
                    imagePath: 'assets/buttons/red_button.png',
                    label: 'Ana Ekrana Dön',
                    textColor: Colors.white,
                    onTap: () => context.go('/game/main'),
                  ),
                  const SizedBox(height: 12),
                  _AssetTextButton(
                    imagePath: 'assets/buttons/red_button.png',
                    label: context.tr('results_menu'),
                    textColor: Colors.white,
                    onTap: () => context.go('/game/main'),
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

/// Asset arka planlı buton (Profil/Ayarlar stili).
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
              fontFamily: AppTheme.titleFontFamily,
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
