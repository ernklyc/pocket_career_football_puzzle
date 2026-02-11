import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/game_button.dart';
import 'package:pocket_career_football_puzzle/services/purchases_service.dart';

/// Coin paywall ekranı.
class PaywallCoinsScreen extends ConsumerStatefulWidget {
  const PaywallCoinsScreen({super.key});

  @override
  ConsumerState<PaywallCoinsScreen> createState() => _PaywallCoinsScreenState();
}

class _PaywallCoinsScreenState extends ConsumerState<PaywallCoinsScreen> {
  List<CoinPackOffering> _offerings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final purchases = ref.read(purchasesServiceProvider);
      _offerings = await purchases.getCoinOfferings();
    } catch (e) {
      // Fallback - devam et butonu her zaman mevcut
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Başlık
              const Icon(
                Icons.monetization_on,
                size: 64,
                color: AppColors.coin,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('paywall_coins_title'),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('paywall_coins_subtitle'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Paketler
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _offerings.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final pack = _offerings[index];
                      return _CoinPackCard(
                        pack: pack,
                        onBuy: () => _onPurchase(pack.id),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Restore Purchases
              TextButton(
                onPressed: _onRestore,
                child: Text(
                  context.tr('paywall_coins_restore'),
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                ),
              ),

              // Devam et
              GameButton(
                text: context.tr('paywall_coins_continue'),
                onPressed: () => context.go('/paywall/remove-ads'),
                width: double.infinity,
                isOutlined: true,
              ),

              const SizedBox(height: 12),

              // Footer
              Text(
                context.tr('paywall_coins_footer'),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),

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

  Future<void> _onPurchase(String packId) async {
    final purchases = ref.read(purchasesServiceProvider);
    await purchases.purchaseCoinPack(packId);
    if (mounted) context.go('/paywall/remove-ads');
  }

  Future<void> _onRestore() async {
    final purchases = ref.read(purchasesServiceProvider);
    await purchases.restorePurchases();
  }
}

class _CoinPackCard extends StatelessWidget {
  final CoinPackOffering pack;
  final VoidCallback onBuy;

  const _CoinPackCard({required this.pack, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.coin.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.monetization_on, color: AppColors.coin, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${pack.coins} Coin',
                  style: const TextStyle(
                    color: AppColors.coin,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(pack.price),
          ),
        ],
      ),
    );
  }
}
