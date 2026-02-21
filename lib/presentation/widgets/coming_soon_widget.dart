import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';

/// İleride yapılacak bölüm gösterimi — Lottie + isteğe bağlı paper.png arka plan.
///
/// [usePaperBackground]: true ise metinler paper.png kutusu içinde gösterilir.
/// false ise (örn. Koleksiyon bölüm kartları) sadece Lottie + metin; arka plan
/// dışarıdaki kart/paper ile sağlanır, üst üste parşömen olmaz.
class ComingSoonWidget extends StatelessWidget {
  final bool fullPage;
  /// İleride yapılacak metinlerinin paper.png arka planında gösterilip gösterilmeyeceği.
  final bool usePaperBackground;

  const ComingSoonWidget({
    super.key,
    this.fullPage = false,
    this.usePaperBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final lottieSize = fullPage ? 140.0 : 100.0;

    final textContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'İleride yapılacak',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.titleFontFamily,
            color: AppColors.parchmentText,
            fontSize: fullPage ? 20 : 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bu bölüm geliştirme aşamasındadır.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.parchmentTextSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );

    final content = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: lottieSize,
              height: lottieSize,
              child: Lottie.asset(
                'assets/lottie/Under Maintenance.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 20),
            if (usePaperBackground)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/buttons/paper.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: textContent,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: textContent,
              ),
          ],
        ),
      ),
    );

    return content;
  }
}
