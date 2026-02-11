import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Banner reklam placeholder widget'ı.
class BannerAdWidget extends ConsumerWidget {
  final String route;

  const BannerAdWidget({super.key, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShow = ref.watch(adsGateProvider(route));

    if (!shouldShow) return const SizedBox.shrink();

    // TODO: Gerçek AdMob banner widget ile değiştirilecek
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: AppColors.surface.withValues(alpha: 0.3)),
        ),
      ),
      child: const Center(
        child: Text(
          'AD PLACEHOLDER',
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
