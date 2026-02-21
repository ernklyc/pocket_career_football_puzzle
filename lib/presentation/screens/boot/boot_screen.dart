import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Açılış / Splash ekranı.
class BootScreen extends ConsumerWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(appBootstrapProvider);

    bootstrap.when(
      data: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final onboardingDone = ref.read(onboardingCompletedProvider);
          if (!onboardingDone) {
            context.go('/onboarding');
          } else {
            // Kariyer var mı kontrol et
            final hasCareer = ref.read(careerServiceProvider).hasCareer;
            if (hasCareer) {
              context.go('/game/main');
            } else {
              context.go('/career/setup');
            }
          }
        });
      },
      loading: () {},
      error: (e, _) {
        // Hata durumunda kariyer kontrolü yap
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final hasCareer = ref.read(careerServiceProvider).hasCareer;
          if (hasCareer) {
            context.go('/game/main');
          } else {
            context.go('/career/setup');
          }
        });
      },
    );

    final isLoading = bootstrap.isLoading;

    final size = MediaQuery.sizeOf(context);
    final splashHeight = (size.shortestSide * 0.28).clamp(120.0, 200.0);
    final textLogoHeight = (size.shortestSide * 0.16).clamp(70.0, 120.0);
    final progressWidth = (size.width * 0.5).clamp(160.0, 240.0);
    final spacingLogoText = size.height * 0.02;
    final spacingTextProgress = size.height * 0.04;

    return Scaffold(
      backgroundColor: AppColors.fieldGreenDark,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/buttons/background.png',
                fit: BoxFit.cover,
              ),
            ),
            Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo/splash.png',
                    height: splashHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: spacingLogoText),
                  Image.asset(
                    'assets/logo/text_logo.png',
                    height: textLogoHeight,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: spacingTextProgress),
                  SizedBox(
                    width: progressWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          Text(
                            'Bulmacalar hazırlanıyor...',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFontFamily,
                              color: Colors.white,
                              fontSize: (size.width * 0.032).clamp(11.0, 14.0),
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        if (isLoading) const SizedBox(height: 10),
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.5),
                            child: isLoading
                                ? LinearProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryLight,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
