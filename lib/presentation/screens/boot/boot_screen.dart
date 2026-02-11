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

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan — home ile aynı
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
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'POCKET CAREER',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Football Puzzle',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: AppColors.accent,
                      fontSize: 16,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (isLoading)
                          Text(
                            'Bulmacalar hazırlanıyor...',
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: AppColors.parchmentTextSecondary,
                              fontSize: 12,
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
