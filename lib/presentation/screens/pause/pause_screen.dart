import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/shadowed_asset.dart';

/// Duraklat ekranı — GameScreen/HomePage tasarım dili: background, paper kart, asset ikon, gölgeler.
class PauseScreen extends StatelessWidget {
  const PauseScreen({super.key});

  static const _cardShadow = [
    BoxShadow(
      color: Colors.black26,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: HomeLayout.screenHorizontalPadding + 16,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Container(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadowedAsset(
                          imagePath: 'assets/buttons/pause.png',
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.tr('pause_title'),
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: AppColors.parchmentText,
                            fontSize: 24,
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
                        const SizedBox(height: 32),
                        _AssetTextButton(
                          imagePath: 'assets/buttons/play_button_v2.png',
                          label: context.tr('pause_resume'),
                          textColor: AppColors.fieldGreenDark,
                          onTap: () => context.pop(),
                        ),
                        const SizedBox(height: 12),
                        _AssetTextButton(
                          imagePath: 'assets/buttons/red_button.png',
                          label: context.tr('pause_quit'),
                          textColor: Colors.white,
                          onTap: () => _showQuitDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/buttons/paper.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.tr('pause_quit'),
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 20,
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
              const SizedBox(height: 12),
              Text(
                context.tr('pause_quit_confirm'),
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      context.tr('cancel'),
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.parchmentText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/game/main');
                    },
                    child: Text(
                      context.tr('pause_quit'),
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asset arka planlı, ortada metinli buton (home OYNA stili).
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
