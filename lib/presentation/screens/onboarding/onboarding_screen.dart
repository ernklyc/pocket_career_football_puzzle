import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/game_button.dart';

/// Onboarding ekranı (ilk açılışta gösterilir). Tam ekran, responsive, parşömen teması.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _OnboardingSlide(
      icon: Icons.sports_soccer,
      titleKey: 'onboarding_slide1',
      color: AppColors.primaryLight,
    ),
    _OnboardingSlide(
      icon: Icons.extension,
      titleKey: 'onboarding_slide2',
      color: AppColors.accent,
    ),
    _OnboardingSlide(
      icon: Icons.emoji_events,
      titleKey: 'onboarding_slide3',
      color: AppColors.goal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    ref.read(localStorageProvider).setOnboardingCompleted(true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
    context.go('/career/setup');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final paddingH = (size.width * 0.08).clamp(24.0, 40.0);
    final iconSize = (size.shortestSide * 0.22).clamp(100.0, 180.0);
    final titleFontSize = (size.width * 0.055).clamp(18.0, 26.0);

    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/league/1.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      context.tr('onboarding_skip'),
                      style: TextStyle(
                        color: AppColors.parchmentText,
                        fontFamily: AppTheme.titleFontFamily,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: paddingH),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: size.height * 0.04),
                            Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: slide.color.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: slide.color,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Icon(
                                slide.icon,
                                size: iconSize * 0.5,
                                color: slide.color,
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),
                            _OnboardingPaperCard(
                              child: Text(
                                context.tr(slide.titleKey),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFontFamily,
                                  color: AppColors.parchmentText,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.accent
                            : AppColors.parchmentBorder.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: _currentPage == _slides.length - 1
                      ? GameButton(
                          text: context.tr('onboarding_start'),
                          onPressed: _completeOnboarding,
                          width: double.infinity,
                          backgroundColor: AppColors.primaryLight,
                          textColor: Colors.white,
                        )
                      : GameButton(
                          text: context.tr('onboarding_next'),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          width: double.infinity,
                          backgroundColor: AppColors.accent,
                          textColor: AppColors.parchmentText,
                        ),
                ),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _OnboardingPaperCard extends StatelessWidget {
  final Widget child;

  const _OnboardingPaperCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
      child: child,
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String titleKey;
  final Color color;

  const _OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.color,
  });
}
