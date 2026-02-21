import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/game_button.dart';

/// Onboarding ekranı — ilk açılışta gösterilir.
/// Tam ekran, responsive, parşömen + futbol temasıyla uyumlu.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const _slides = [
    _OnboardingSlide(
      iconAsset: 'assets/buttons/ball.png',
      titleKey: 'onboarding_slide1',
      accentColor: AppColors.primaryLight,
    ),
    _OnboardingSlide(
      iconAsset: 'assets/buttons/board.png',
      titleKey: 'onboarding_slide2',
      accentColor: AppColors.accent,
    ),
    _OnboardingSlide(
      iconAsset: 'assets/buttons/trophy.png',
      titleKey: 'onboarding_slide3',
      accentColor: AppColors.goal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _fadeController
      ..reset()
      ..forward();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _completeOnboarding() {
    ref.read(localStorageProvider).setOnboardingCompleted(true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
    context.go('/career/setup');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final paddingH = (size.width * 0.08).clamp(24.0, 44.0);
    final iconSize = (size.shortestSide * 0.22).clamp(90.0, 170.0);
    final titleFontSize = (size.width * 0.055).clamp(17.0, 26.0);
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background — same as Splash for visual continuity ──────────
          Image.asset('assets/buttons/background.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.50),
                ],
              ),
            ),
          ),

          // ── Main column ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar: Logo + Skip
                Padding(
                  padding: EdgeInsets.fromLTRB(paddingH, 8, 16, 4),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/logo/text_logo.png',
                        height: (size.shortestSide * 0.09).clamp(36.0, 56.0),
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                      _SkipButton(onTap: _completeOnboarding),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: paddingH),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon area — themed asset on parchment oval
                              _SlideIconBox(
                                iconAsset: slide.iconAsset,
                                accentColor: slide.accentColor,
                                size: iconSize,
                              ),
                              SizedBox(height: size.height * 0.04),

                              // Content card (parchment)
                              _OnboardingPaperCard(
                                child: Text(
                                  context.tr(slide.titleKey),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.titleFontFamily,
                                    color: AppColors.parchmentText,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x44000000),
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Dot indicator
                _DotIndicator(count: _slides.length, current: _currentPage),
                SizedBox(height: size.height * 0.025),

                // Action button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: isLast
                      ? GameButton(
                          text: context.tr('onboarding_start'),
                          onPressed: _completeOnboarding,
                          width: double.infinity,
                          backgroundColor: AppColors.primaryLight,
                          textColor: Colors.white,
                        )
                      : GameButton(
                          text: context.tr('onboarding_next'),
                          onPressed: _nextPage,
                          width: double.infinity,
                          backgroundColor: AppColors.accent,
                          textColor: AppColors.parchmentText,
                        ),
                ),
                SizedBox(height: (size.height * 0.04).clamp(20.0, 48.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────

/// Styled "Atla" butonu — parşömen renkli çerçeveyle görünür.
class _SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SkipButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.parchmentBorder.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Text(
          context.tr('onboarding_skip'),
          style: TextStyle(
            fontFamily: AppTheme.titleFontFamily,
            color: AppColors.parchmentFill,
            fontSize: 13,
            letterSpacing: 0.3,
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slayt için tematik ikon kutusu — asset + altın border + glow.
class _SlideIconBox extends StatelessWidget {
  final String iconAsset;
  final Color accentColor;
  final double size;

  const _SlideIconBox({
    required this.iconAsset,
    required this.accentColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.15),
        border: Border.all(
          color: AppColors.parchmentBorder.withValues(alpha: 0.65),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.22),
            offset: const Offset(0, 0),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 5),
            blurRadius: 14,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.18),
        child: Image.asset(iconAsset, fit: BoxFit.contain),
      ),
    );
  }
}

/// Dot page indicator — animasyonlu genişleme.
class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent
                : AppColors.parchmentBorder.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Parşömen kağıt kart  — slayt metnini içine alır.
class _OnboardingPaperCard extends StatelessWidget {
  final Widget child;

  const _OnboardingPaperCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/paper.png'),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 6),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.parchmentBorder.withValues(alpha: 0.12),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Slide veri modeli.
class _OnboardingSlide {
  final String iconAsset;
  final String titleKey;
  final Color accentColor;

  const _OnboardingSlide({
    required this.iconAsset,
    required this.titleKey,
    required this.accentColor,
  });
}
