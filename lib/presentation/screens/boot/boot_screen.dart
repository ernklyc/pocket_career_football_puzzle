import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Açılış / Splash ekranı — tam responsive, parşömen temasıyla uyumlu.
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
    final splashHeight = (size.shortestSide * 0.30).clamp(130.0, 210.0);
    final textLogoHeight = (size.shortestSide * 0.17).clamp(75.0, 130.0);
    final progressWidth = (size.width * 0.52).clamp(170.0, 260.0);
    final spacingLogoText = (size.height * 0.022).clamp(12.0, 28.0);
    final spacingTextProgress = (size.height * 0.045).clamp(20.0, 52.0);

    return Scaffold(
      backgroundColor: AppColors.fieldGreenDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────────────────
          Image.asset('assets/buttons/background.png', fit: BoxFit.cover),

          // ── Dark gradient overlay for depth ───────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),

          // ── Main content — SafeArea wraps everything ───────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Splash logo
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/logo/splash.png',
                        height: splashHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: spacingLogoText),

                    // Text logo
                    Image.asset(
                      'assets/logo/text_logo.png',
                      height: textLogoHeight,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: spacingTextProgress),

                    // Loading section
                    SizedBox(
                      width: progressWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLoading) ...[
                            Text(
                              'Bulmacalar hazırlanıyor...',
                              style: TextStyle(
                                fontFamily: AppTheme.titleFontFamily,
                                color: Colors.white,
                                fontSize: (size.width * 0.033).clamp(
                                  11.0,
                                  15.0,
                                ),
                                letterSpacing: 0.5,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          _SplashProgressBar(isLoading: isLoading),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animasyonlu, parlayan yükleme çubuğu.
class _SplashProgressBar extends StatefulWidget {
  final bool isLoading;

  const _SplashProgressBar({required this.isLoading});

  @override
  State<_SplashProgressBar> createState() => _SplashProgressBarState();
}

class _SplashProgressBarState extends State<_SplashProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: widget.isLoading
          ? AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ShimmerBarPainter(
                    progress: _shimmerController.value,
                    barColor: AppColors.primaryLight,
                    glowColor: AppColors.accentLight,
                  ),
                );
              },
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Shimmer animasyonlu progress bar painter.
class _ShimmerBarPainter extends CustomPainter {
  final double progress;
  final Color barColor;
  final Color glowColor;

  _ShimmerBarPainter({
    required this.progress,
    required this.barColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Döngüsel animasyon: 0→1→0 (ease)
    final t = math.sin(progress * math.pi);
    final fillWidth = size.width * (0.3 + 0.7 * t);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      const Radius.circular(5),
    );

    // Glow fill
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [barColor, glowColor, barColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(rrect, glowPaint);

    // Solid fill on top
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [barColor, glowColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, fillWidth, size.height));
    canvas.drawRRect(rrect, fillPaint);
  }

  @override
  bool shouldRepaint(_ShimmerBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
