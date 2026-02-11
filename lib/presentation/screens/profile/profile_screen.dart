import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/domain/entities/career.dart';
import 'package:pocket_career_football_puzzle/domain/entities/achievement.dart';
import 'package:pocket_career_football_puzzle/services/progress_service.dart';

/// Profil ekranı — overlay olarak açılır, Profil + Ayarlar tab'ları içerir.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final career = ref.watch(activeCareerProvider);
    final progress = ref.watch(progressProvider);

    final team = career != null
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
              // Üst bar — appbar.png ile
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
                        Text(
                          'Profil',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/game/main');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    // Profil başlık kartı
                    if (career != null && team != null) ...[
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                children: [
                  // Takım logosu (emoji)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(team.primaryColor),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(
                            team.primaryColor,
                          ).withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: team.logoAssetPath != null
                        ? ClipOval(
                            child: Image.asset(
                              team.logoAssetPath!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              team.logoEmoji,
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 28,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tıklanabilir isim düzenleme
                        GestureDetector(
                          onTap: () => _showEditNameDialog(context, ref, career),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                career.playerName,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: AppColors.parchmentText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: AppColors.textHint.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Seviye ${career.currentLevel}',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${progress.totalPoints}',
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

                    const SizedBox(height: 12),

                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AppColors.primaryLight.withValues(alpha: 0.4),
                          ),
                        ),
                        labelColor: AppColors.textPrimary,
                        unselectedLabelColor: AppColors.textHint,
                        labelStyle: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Profil'),
                          Tab(text: 'Ayarlar'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _ProfileTab(
                              career: career, progress: progress, team: team),
                          const _SettingsTab(),
                        ],
                      ),
                    ),
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

  void _showEditNameDialog(BuildContext context, WidgetRef ref, Career career) {
    final controller = TextEditingController(text: career.playerName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'İsim Değiştir',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Oyuncu adı',
            hintStyle: TextStyle(color: AppColors.textHint.withValues(alpha: 0.5)),
            counterStyle: const TextStyle(color: AppColors.textHint),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textHint.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryLight),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(careersProvider.notifier).updatePlayerName(newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ══════════════════════════════════════════════════════════════
// Profil Tab
// ══════════════════════════════════════════════════════════════
class _ProfileTab extends ConsumerWidget {
  final Career? career;
  final ProgressData progress;
  final TeamConfig? team;

  const _ProfileTab({
    required this.career,
    required this.progress,
    required this.team,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (career == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 48,
              color: AppColors.textHint.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aktif kariyer yok',
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Takım bilgisi + değiştir
          GestureDetector(
            onTap: () => _showTeamChangeDialog(context, ref),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (team != null) ...[
                    if (team!.logoAssetPath != null)
                      ClipOval(
                        child: Image.asset(
                          team!.logoAssetPath!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Text(
                        team!.logoEmoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    career!.teamName.isNotEmpty
                        ? career!.teamName
                        : (team?.name ?? ''),
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.swap_horiz,
                    size: 16,
                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Kupa Sergim
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Kupa Sergim',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildTrophyShowcase(progress),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Başarım Rozetleri
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.military_tech,
                      color: AppColors.premium,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Başarımlar',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/achievements'),
                      child: const Text(
                        'Tümü →',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildAchievementCompact(progress, career),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Kariyeri sıfırla
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, ref),
              icon: const Icon(Icons.restart_alt, size: 18),
              label: const Text('Kariyeri Sıfırla'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Kullanıcı kimliği
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 14,
                  color: AppColors.textHint.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Kullanıcı ID: ${career!.id}',
                    style: TextStyle(
                      color: AppColors.textHint.withValues(alpha: 0.5),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyShowcase(ProgressData progress) {
    // Haftalık sıralama kupaları — ilk 3'e girince kazanılır
    // Şimdilik SharedPreferences'tan okunan haftalık kupa sayıları
    // TODO: Gerçek haftalık sıralama sistemi entegrasyonu
    final goldCups = 0; // 1. sıra
    final silverCups = 0; // 2. sıra
    final bronzeCups = 0; // 3. sıra
    final totalCups = goldCups + silverCups + bronzeCups;

    if (totalCups == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 40,
                color: AppColors.textHint.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Henüz kupa yok',
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Haftalık sıralamada ilk 3\'e gir!',
                style: TextStyle(
                  color: AppColors.textHint.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TrophyCup(
          icon: Icons.emoji_events,
          color: AppColors.gold,
          label: '1.',
          count: goldCups,
        ),
        _TrophyCup(
          icon: Icons.emoji_events,
          color: AppColors.silver,
          label: '2.',
          count: silverCups,
        ),
        _TrophyCup(
          icon: Icons.emoji_events,
          color: const Color(0xFFCD7F32),
          label: '3.',
          count: bronzeCups,
        ),
      ],
    );
  }

  Widget _buildAchievementCompact(ProgressData progress, Career? career) {
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
      completedLevelCount:
          progress.levels.values.where((l) => l.completed).length,
      levelMatchPoints: levelMatchPoints,
    );
    final unlocked = Achievements.unlockedAchievements(ctx);
    final total = Achievements.all.length;

    if (unlocked.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Henüz başarım kazanılmadı',
          style: TextStyle(
            color: AppColors.textHint.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      );
    }

    // Son kazanılan 4 başarımı göster
    final display = unlocked.length > 4
        ? unlocked.sublist(unlocked.length - 4)
        : unlocked;

    return Column(
      children: [
        // Kompakt ilerleme
        Row(
          children: [
            Text(
              '${unlocked.length}/$total',
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? unlocked.length / total : 0,
                  minHeight: 5,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Son başarımlar satırı
        Row(
          children: display.map((a) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 2),
                    Text(
                      a.title,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Kariyeri Sıfırla',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Tüm kariyer verisi silinecek. Bu işlem geri alınamaz!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'İptal',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Tüm verileri sil — sıfırdan hesap açmış gibi
              final localStorage = ref.read(localStorageProvider);
              await localStorage.clearAll();
              // Tüm provider'ları yenile
              ref.invalidate(careersProvider);
              ref.invalidate(activeCareerProvider);
              ref.invalidate(progressProvider);
              ref.invalidate(livesProvider);
              ref.invalidate(coinBalanceProvider);
              ref.invalidate(localLeaderboardProvider);
              ref.invalidate(activeCosmeticsProvider);
              ref.invalidate(settingsProvider);
              if (context.mounted) {
                context.go('/career/setup');
              }
            },
            child: const Text(
              'Sıfırla',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTeamChangeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Takım Değiştir',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: AppConfig.availableTeams.length,
            itemBuilder: (_, i) {
              final t = AppConfig.availableTeams[i];
              final isSelected = t.id == career?.teamId;
              return GestureDetector(
                onTap: () {
                  ref.read(careersProvider.notifier).updateTeamId(t.id);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(t.primaryColor).withValues(alpha: 0.2)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: Color(t.primaryColor), width: 2)
                        : null,
                  ),
                  child: Center(
                    child: t.logoAssetPath != null
                        ? ClipOval(
                            child: Image.asset(
                              t.logoAssetPath!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            t.logoEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TrophyCup extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;

  const _TrophyCup({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            if (count > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$label s\u0131ra',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Ayarlar Tab
// ══════════════════════════════════════════════════════════════
class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isPremium = ref.watch(entitlementProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: context.tr('settings_language'),
          child: Row(
            children: [
              _LanguageChip(
                label: 'Türkçe',
                isSelected: settings.language == 'tr',
                onTap: () =>
                    ref.read(settingsProvider.notifier).updateLanguage('tr'),
              ),
              const SizedBox(width: 8),
              _LanguageChip(
                label: 'English',
                isSelected: settings.language == 'en',
                onTap: () =>
                    ref.read(settingsProvider.notifier).updateLanguage('en'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Ses & Titreşim',
          child: Column(
            children: [
              _ToggleRow(
                icon: Icons.music_note,
                label: context.tr('settings_music'),
                value: settings.musicEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleMusic(v),
              ),
              _ToggleRow(
                icon: Icons.volume_up,
                label: context.tr('settings_sound'),
                value: settings.soundEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleSound(v),
              ),
              _ToggleRow(
                icon: Icons.vibration,
                label: context.tr('settings_haptics'),
                value: settings.hapticsEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleHaptics(v),
              ),
              _ToggleRow(
                icon: Icons.notifications,
                label: context.tr('settings_notifications'),
                value: settings.notificationsEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleNotifications(v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Satın Alma',
          child: Column(
            children: [
              if (!isPremium)
                _ActionRow(
                  icon: Icons.block,
                  label: context.tr('settings_remove_ads'),
                  color: AppColors.premium,
                  onTap: () => context.go('/paywall/remove-ads'),
                ),
              _ActionRow(
                icon: Icons.monetization_on_outlined,
                label: 'Coin Satın Al',
                color: AppColors.accent,
                onTap: () => context.push('/shop'),
              ),
              _ActionRow(
                icon: Icons.restore,
                label: context.tr('settings_restore_purchases'),
                onTap: () async {
                  final purchases = ref.read(purchasesServiceProvider);
                  final success = await purchases.restorePurchases();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Satın alımlar geri yüklendi'
                              : 'Geri yükleme başarısız',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: 'Destek & Yasal',
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.star_rate_outlined,
                label: 'Bizi Değerlendir',
                color: AppColors.accent,
                onTap: () {
                  // TODO: Store review açılacak
                },
              ),
              _ActionRow(
                icon: Icons.help_outline,
                label: 'Yardım',
                onTap: () {
                  // TODO: Yardım sayfası
                },
              ),
              _ActionRow(
                icon: Icons.privacy_tip,
                label: 'Gizlilik Politikası',
                onTap: () {
                  // TODO: URL launcher ile açılacak
                },
              ),
              _ActionRow(
                icon: Icons.description,
                label: 'Kullanım Koşulları',
                onTap: () {
                  // TODO: URL launcher ile açılacak
                },
              ),
              _ActionRow(
                icon: Icons.language,
                label: 'Web Sitesi',
                onTap: () {
                  // TODO: URL launcher ile açılacak
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '${context.tr('settings_version')}: ${AppConfig.appVersion}',
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SettingsSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(color: color ?? AppColors.textPrimary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.textHint.withValues(alpha: 0.5),
        size: 20,
      ),
      onTap: onTap,
      dense: true,
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.surfaceLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryLight : AppColors.textHint,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
