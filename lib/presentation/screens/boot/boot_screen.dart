import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan — yeşil saha
          Positioned.fill(
            child: Image.asset(
              'assets/league/5.png',
              fit: BoxFit.cover,
            ),
          ),
          // Ortada logo + text logo + progress
          Center(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ortada logo (top + platform)
                  Image.asset(
                    'assets/logo/splash.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  // Oyun ismi — text logo
                  Image.asset(
                    'assets/logo/text_logo.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLoading)
                          Text(
                            'Bulmacalar hazırlanıyor...',
                            style: TextStyle(
                              fontFamily: AppTheme.bodyFontFamily,
                              color: Colors.white,
                              fontSize: 12,
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
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
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
    );
  }
}
