import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/domain/entities/achievement.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Başarımlar ekranı.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    // AchievementContext oluştur
    final levelMatchPoints = <int, int>{};
    for (final entry in progress.levels.entries) {
      final levelNum = int.tryParse(entry.key);
      if (levelNum != null) {
        levelMatchPoints[levelNum] = entry.value.matchPoints;
      }
    }

    final ctx = AchievementContext(
      currentLevel: progress.currentLevel,
      totalPoints: progress.totalPoints,
      completedLevelCount: progress.levels.values.where((l) => l.completed).length,
      levelMatchPoints: levelMatchPoints,
    );

    final unlocked = Achievements.unlockedAchievements(ctx);
    final locked = Achievements.lockedAchievements(ctx);

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
                          'Başarımlar',
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
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Özet kartı
                    _SummaryCard(
                      unlockedCount: unlocked.length,
                      totalCount: Achievements.all.length,
                    ),
                    const SizedBox(height: 20),

                    // Açık başarımlar
                    if (unlocked.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Kazanılan Başarımlar',
                        count: unlocked.length,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      ...unlocked
                          .map((a) => _AchievementCard(
                                achievement: a,
                                isUnlocked: true,
                              )),
                      const SizedBox(height: 20),
                    ],

                    // Kilitli başarımlar
                    if (locked.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Kilitli Başarımlar',
                        count: locked.length,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      ...locked
                          .map((a) => _AchievementCard(
                                achievement: a,
                                isUnlocked: false,
                              )),
                    ],
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

/// Üst özet kartı.
class _SummaryCard extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;

  const _SummaryCard({
    required this.unlockedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/buttons/paper.png'),
          fit: BoxFit.cover,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _SummaryItem(
                value: '$unlockedCount/$totalCount',
                label: 'Başarım',
                color: AppColors.accent,
              ),
              _SummaryItem(
                value: '%$percentage',
                label: 'İlerleme',
                color: AppColors.info,
              ),
            ],
          ),
          const SizedBox(height: 14),
          // İlerleme çubuğu
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalCount > 0 ? unlockedCount / totalCount : 0,
              minHeight: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: AppTheme.fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.parchmentTextSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Bölüm başlığı.
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Tek bir başarım kartı.
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel = switch (achievement.category) {
      AchievementCategory.chapter => 'Bölge',
      AchievementCategory.blockUnlock => 'Blok',
      AchievementCategory.points => 'Seviye',
    };

    final categoryColor = switch (achievement.category) {
      AchievementCategory.chapter => AppColors.info,
      AchievementCategory.blockUnlock => AppColors.accent,
      AchievementCategory.points => AppColors.success,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        border: Border.all(
          color: isUnlocked
              ? categoryColor.withValues(alpha: 0.4)
              : AppColors.surfaceLight.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Emoji / Lock
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? categoryColor.withValues(alpha: 0.2)
                  : AppColors.surfaceLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isUnlocked
                  ? Text(
                      achievement.emoji,
                      style: const TextStyle(fontSize: 22),
                    )
                  : const Icon(
                      Icons.lock_outline,
                      color: AppColors.textHint,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Başlık + açıklama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color:
                              isUnlocked ? AppColors.parchmentText : AppColors.textHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // Kategori etiketi
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categoryLabel,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: isUnlocked ? AppColors.textSecondary : AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Tamamlandı ikonu
          if (isUnlocked)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
