import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/config/economy_config.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/domain/entities/shop_item.dart';
import 'package:pocket_career_football_puzzle/domain/entities/transaction.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/coin_display.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/banner_ad_widget.dart';

/// Mağaza ekranı.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shopItemsProvider);
    final balance = ref.watch(coinBalanceProvider);

    final powerUps = items.where((i) => i.type == ShopItemType.powerUp).toList();
    final cosmetics = items.where((i) => i.type == ShopItemType.cosmetic).toList();
    final unlocks = items.where((i) => i.type == ShopItemType.unlock).toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/buttons/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Üst bar
              Container(
                constraints: const BoxConstraints(minHeight: 64),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/buttons/appbar.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/game/main');
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('shop_title'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: CoinDisplay(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Ödüllü reklam
                    _RewardedAdCard(),
                    const SizedBox(height: 20),

                    // Power-ups
                    if (powerUps.isNotEmpty) ...[
                      _SectionTitle(title: 'Power-ups', icon: Icons.flash_on),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          children: [
                            ...powerUps.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ShopItemCard(
                                  item: item,
                                  balance: balance,
                                  onBuy: () => _buyItem(item),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Cosmetics
                    if (cosmetics.isNotEmpty) ...[
                      _SectionTitle(title: 'Cosmetics', icon: Icons.style),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          children: [
                            ...cosmetics.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ShopItemCard(
                                  item: item,
                                  balance: balance,
                                  onBuy: () => _buyItem(item),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Unlocks
                    if (unlocks.isNotEmpty) ...[
                      _SectionTitle(title: 'Unlocks', icon: Icons.lock_open),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Column(
                          children: [
                            ...unlocks.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _ShopItemCard(
                                  item: item,
                                  balance: balance,
                                  onBuy: () => _buyItem(item),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const BannerAdWidget(route: '/shop'),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _buyItem(ShopItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr('shop_buy')),
        content: Text(
          context.tr('shop_confirm_purchase', params: {
            'item': context.tr(item.nameKey),
            'price': '${item.coinPrice}',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.tr('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr('shop_buy')),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await ref.read(inventoryServiceProvider).purchaseItem(item.id);
      if (!mounted) return;
      if (ok) {
        ref.read(coinBalanceProvider.notifier).refresh();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('shop_purchase_success'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('shop_not_enough_coins'))),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final int balance;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.item,
    required this.balance,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = balance >= item.coinPrice;
    final isOwned = item.isOwned && item.type != ShopItemType.powerUp;

    IconData itemIcon;
    switch (item.id) {
      case 'extra_move':
        itemIcon = Icons.add_circle;
        break;
      case 'reset_level':
        itemIcon = Icons.refresh;
        break;
      case 'jersey_1':
        itemIcon = Icons.checkroom;
        break;
      case 'boot_1':
        itemIcon = Icons.directions_run;
        break;
      case 'badge_1':
        itemIcon = Icons.military_tech;
        break;
      case 'trophy_slot':
        itemIcon = Icons.emoji_events;
        break;
      default:
        itemIcon = Icons.shopping_bag;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getTypeColor(item.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(itemIcon, color: _getTypeColor(item.type), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(item.nameKey),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.tr(item.descriptionKey),
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 11,
                  ),
                ),
                if (item.type == ShopItemType.powerUp && item.quantity > 0)
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (isOwned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.tr('shop_owned'),
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: canAfford ? onBuy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canAfford ? AppColors.accent : AppColors.surfaceLight,
                foregroundColor: canAfford ? AppColors.background : AppColors.textHint,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 14,
                    color: canAfford ? AppColors.coinDark : AppColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Text('${item.coinPrice}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(ShopItemType type) {
    switch (type) {
      case ShopItemType.powerUp:
        return AppColors.accent;
      case ShopItemType.cosmetic:
        return AppColors.premium;
      case ShopItemType.unlock:
        return AppColors.info;
    }
  }
}

class _RewardedAdCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsServiceProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.15),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill, color: AppColors.accent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('rewarded_watch_ad', params: {
                    'coins': '${EconomyConfig.rewardedAdCoinGrant}',
                  }),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ads.isRewardedOnCooldown)
                  Text(
                    context.tr('rewarded_ad_cooldown'),
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: ads.canShowRewarded
                ? () async {
                    final success = await ads.showRewarded();
                    if (success) {
                      await ref.read(coinBalanceProvider.notifier).addCoins(
                            EconomyConfig.rewardedAdCoinGrant,
                            'rewarded_ad',
                            TransactionSource.rewardedAd,
                          );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
            ),
            child: const Icon(Icons.play_arrow),
          ),
        ],
      ),
    );
  }
}
