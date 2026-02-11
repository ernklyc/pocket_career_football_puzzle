import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/game_button.dart';

/// Reklam kaldırma paywall ekranı.
class PaywallRemoveAdsScreen extends ConsumerWidget {
  const PaywallRemoveAdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(entitlementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // İkon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.premium.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block,
                  size: 50,
                  color: AppColors.premium,
                ),
              ),
              const SizedBox(height: 24),

              // Başlık
              Text(
                context.tr('paywall_remove_ads_title'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Açıklama: Reklamsız izle + sınırsız can
              const Text(
                'Reklamsız izle ve sınırsız can sahibi ol.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('paywall_remove_ads_note'),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (isPremium)
                // Zaten satın alınmış
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('paywall_remove_ads_owned'),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Satın al butonu
                GameButton(
                  text: '${context.tr('paywall_remove_ads_buy')} - ₺49.99',
                  onPressed: () async {
                    final purchases = ref.read(purchasesServiceProvider);
                    final success = await purchases.purchaseRemoveAds();
                    if (success) {
                      ref.read(entitlementProvider.notifier).state = true;
                      ref.read(adsServiceProvider).setPremiumActive(true);
                    }
                  },
                  width: double.infinity,
                  backgroundColor: AppColors.premium,
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('paywall_remove_ads_one_time'),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
              ],

              const Spacer(),

              // Restore Purchases
              TextButton(
                onPressed: () async {
                  final purchases = ref.read(purchasesServiceProvider);
                  await purchases.restorePurchases();
                },
                child: Text(
                  context.tr('paywall_remove_ads_restore'),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ),

              // Devam et
              GameButton(
                text: context.tr('paywall_remove_ads_continue'),
                onPressed: () {
                  final nextLevel = ref.read(nextLevelAfterPaywallProvider);
                  ref.read(nextLevelAfterPaywallProvider.notifier).state = null;
                  if (nextLevel != null) {
                    context.go('/play', extra: {'season': 1, 'level': nextLevel});
                  } else {
                    context.go('/game/main');
                  }
                },
                width: double.infinity,
                isOutlined: true,
              ),

              const SizedBox(height: 12),

              // Legal linkler
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(color: AppColors.textHint, fontSize: 10),
                    ),
                  ),
                  const Text(' | ', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Terms of Service',
                      style: TextStyle(color: AppColors.textHint, fontSize: 10),
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
