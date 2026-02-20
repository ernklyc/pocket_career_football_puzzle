import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/theme/layout_constants.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/coin_display.dart';

/// Ana menü ekranı.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(entitlementProvider);
    final activeCareer = ref.watch(activeCareerProvider);

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
              // Üst bar — appbar.png
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
                    padding: HomeLayout.barPadding,
                    child: Row(
                      children: [
                        if (isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.premium.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star,
                                    color: AppColors.premium, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: AppColors.premium,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        const Spacer(),
                        const CoinDisplay(),
                      ],
                    ),
                  ),
                ),
              ),

              // Orta içerik — tek büyük paper kart
              Expanded(
                child: SingleChildScrollView(
                  padding: HomeLayout.contentPadding,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo ve başlık
                            const Icon(
                              Icons.sports_soccer,
                              size: 72,
                              color: AppColors.primaryLight,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'POCKET CAREER',
                              style: TextStyle(
                                fontFamily: AppTheme.titleFontFamily,
                                color: AppColors.parchmentText,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'Football Puzzle',
                              style: TextStyle(
                                fontFamily: AppTheme.bodyFontFamily,
                                color: AppColors.parchmentTextSecondary,
                                fontSize: 12,
                                letterSpacing: 1.4,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Aktif kariyer bilgisi
                            if (activeCareer != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight.withValues(
                                      alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: AppColors.primaryLight),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            activeCareer.playerName,
                                            style: TextStyle(
                                              fontFamily: AppTheme.bodyFontFamily,
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            'S${activeCareer.currentSeason} - L${activeCareer.currentLevel}',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                        color: AppColors.textHint),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Menü butonları
                            _MenuButton(
                              icon: Icons.play_arrow,
                              label: context.tr('menu_play'),
                              color: AppColors.primaryLight,
                              onTap: () {
                                if (activeCareer != null) {
                                  context.go('/map');
                                } else {
                                  context.go('/career');
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.person,
                                    label: context.tr('menu_career'),
                                    color: AppColors.info,
                                    onTap: () => context.go('/career'),
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.map,
                                    label: context.tr('menu_map'),
                                    color: AppColors.fieldGreen,
                                    onTap: () => context.go('/map'),
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.store,
                                    label: context.tr('menu_shop'),
                                    color: AppColors.accent,
                                    onTap: () => context.go('/shop'),
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.leaderboard,
                                    label: context.tr('menu_leaderboard'),
                                    color: AppColors.gold,
                                    onTap: () => context.go('/leaderboard'),
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.emoji_events,
                                    label: 'Başarımlar',
                                    color: AppColors.gold,
                                    onTap: () =>
                                        context.go('/achievements'),
                                    compact: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.grid_view_rounded,
                                    label: 'Koleksiyon',
                                    color: AppColors.premium,
                                    onTap: () => context.go('/collection'),
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuButton(
                                    icon: Icons.settings,
                                    label: context.tr('menu_settings'),
                                    color: AppColors.textSecondary,
                                    onTap: () => context.go('/profile'),
                                    compact: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom bar
              Container(
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/buttons/bottom_nav_bar.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, -4),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const SafeArea(
                  top: false,
                  child: SizedBox(height: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 18 : 22,
            vertical: compact ? 12 : 16,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: compact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: compact ? 22 : 26),
              SizedBox(width: compact ? 8 : 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.bodyFontFamily,
                  color: AppColors.textPrimary,
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
