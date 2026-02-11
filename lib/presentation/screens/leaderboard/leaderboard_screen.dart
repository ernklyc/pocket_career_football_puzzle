import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/banner_ad_widget.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/domain/entities/leaderboard_entry.dart';

/// Sıralama ekranı — Haftalık & Tüm Zamanlar sekmeleriyle.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedTab = 0; // 0 = Haftalık, 1 = Tüm Zamanlar
  late Timer _countdownTimer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _updateRemainingTime(),
    );
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    // Hafta sonu: Pazartesi 00:00
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMonday = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
    final diff = nextMonday.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    setState(() {
      _remainingTime = '${days}g ${hours}s';
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(localLeaderboardProvider);
    final career = ref.watch(activeCareerProvider);
    final progress = ref.watch(progressProvider);

    // Kullanıcının sıralamasını bul
    final userIndex = entries.indexWhere((e) => e.isCurrentUser);
    final userRank = userIndex >= 0 ? userIndex + 1 : null;
    final userScore = progress.totalPoints;
    final userName = career?.playerName ?? 'Sen';
    final userTeamName = career?.teamName ?? '';
    final userLevel = career?.currentLevel ?? 1;
    final userTeam = career != null
        ? AppConfig.availableTeams.firstWhere(
            (t) => t.id == career.teamId,
            orElse: () => AppConfig.availableTeams.first,
          )
        : null;

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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      offset: Offset(0, 4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.go('/game/main'),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sıralama',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // ── Tab bar: Haftalık / Tüm Zamanlar ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'Haftalık',
                              subtitle: _remainingTime,
                              isSelected: _selectedTab == 0,
                              onTap: () => setState(() => _selectedTab = 0),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TabButton(
                              label: 'Tüm Zamanlar',
                              subtitle: career != null
                                  ? '${DateTime.now().difference(career.createdAt).inDays} gün'
                                  : null,
                              isSelected: _selectedTab == 1,
                              onTap: () => setState(() => _selectedTab = 1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Liste ──
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.leaderboard_outlined,
                                    size: 60,
                                    color:
                                        AppColors.textHint.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Henüz skor yok. Oynamaya başla!',
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      color: AppColors.textHint
                                          .withValues(alpha: 0.5),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return _LeaderboardCard(
                                  entry: entry,
                                  rank: index + 1,
                                );
                              },
                            ),
                    ),

                    // ── Kullanıcının kendi sırası (sabitlenmiş) ──
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/buttons/paper.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.primaryLight.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Sıra numarası
                          SizedBox(
                            width: 36,
                            child: Text(
                              userRank != null ? '$userRank' : '-',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                color: AppColors.primaryLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Avatar — takım logosu
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child:
                                  userTeam != null && userTeam.logoAssetPath != null
                                      ? ClipOval(
                                          child: Image.asset(
                                            userTeam.logoAssetPath!,
                                            width: 36,
                                            height: 36,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Text(
                                          userTeam?.logoEmoji ?? '⚽',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // İsim + takım adı
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userTeamName.isNotEmpty
                                      ? '$userName - $userTeamName'
                                      : userName,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.parchmentText,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Seviye $userLevel',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.parchmentTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Skor
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$userScore',
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Bilgilendirme ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                      child: Text(
                        'Haftalık ilk 3\'e girenler ödül ve kupa ile ödüllendirilir.',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: AppColors.parchmentTextSecondary
                              .withValues(alpha: 0.9),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const BannerAdWidget(route: '/leaderboard'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tab Butonu ──
class _TabButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceLight.withValues(alpha: 0.95)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.7)
                : AppColors.surfaceLight.withValues(alpha: 0.7),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color:
                    isSelected ? AppColors.primaryLight : AppColors.parchmentText,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isSelected
                      ? AppColors.primaryLight.withValues(alpha: 0.8)
                      : AppColors.parchmentTextSecondary.withValues(alpha: 0.9),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Sıralama Kartı ──
class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const _LeaderboardCard({required this.entry, required this.rank});

  @override
  Widget build(BuildContext context) {
    Color? medalColor;
    Color? medalBg;
    if (rank == 1) {
      medalColor = AppColors.gold;
      medalBg = AppColors.gold.withValues(alpha: 0.15);
    } else if (rank == 2) {
      medalColor = AppColors.silver;
      medalBg = AppColors.silver.withValues(alpha: 0.15);
    } else if (rank == 3) {
      medalColor = AppColors.bronze;
      medalBg = AppColors.bronze.withValues(alpha: 0.15);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/paper.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
        border: rank <= 3
            ? Border.all(
                color: (medalColor ?? Colors.transparent).withValues(alpha: 0.5),
              )
            : entry.isCurrentUser
                ? Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                  )
                : Border.all(
                    color: AppColors.surfaceLight.withValues(alpha: 0.4),
                  ),
      ),
      child: Row(
        children: [
          // Sıra rozeti
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalBg ?? Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: medalColor ?? AppColors.textHint,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Avatar — takım logosu
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                entry.teamLogoEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // İsim + Takım Adı
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.teamName.isNotEmpty
                      ? '${entry.playerName} - ${entry.teamName}'
                      : entry.playerName,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: entry.isCurrentUser
                        ? AppColors.primaryLight
                        : AppColors.parchmentText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Seviye ${entry.rank > 0 ? entry.rank : '-'}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.parchmentTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Skor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: medalColor ?? AppColors.accent,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry.score}',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
