import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';
import 'package:pocket_career_football_puzzle/domain/entities/career.dart';
import 'package:pocket_career_football_puzzle/services/progress_service.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/app_bar_parchment.dart';

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
              const AppBarParchment(title: 'Hesabım'),
              Expanded(
                child: Column(
                  children: [
                    // Profil başlık kartı
                    if (career != null && team != null) ...[
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/buttons/tabela.png'),
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
                                // Takım logosu
                                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(team.primaryColor),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(team.primaryColor).withValues(alpha: 0.3),
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
                                fontFamily: AppTheme.bodyFontFamily,
                                fontSize: 28,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => _showEditNameDialog(context, ref, career),
                        child: Text(
                          career.playerName,
                          style: TextStyle(
                            fontFamily: AppTheme.titleFontFamily,
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                offset: const Offset(1, 2),
                                blurRadius: 3,
                              ),
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
                            ),
                          // Kalem — paper.png sağ üst köşesi, takım düzenleme
                          Positioned(
                            top: 4,
                            right: 20,
                            child: GestureDetector(
                              onTap: () => _showTeamChangeDialog(context, ref, career),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.parchmentFill,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.parchmentBorder,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: AppColors.parchmentText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Tab Bar — tabela.png arka plan (yüksek, ezilmesin), paper seçili tab'ta
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(minHeight: 60),
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/buttons/tabela.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorPadding: const EdgeInsets.all(6),
                        indicator: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/buttons/paper.png'),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelColor: AppColors.parchmentText,
                        unselectedLabelColor: Colors.white,
                        labelStyle: TextStyle(
                          fontFamily: AppTheme.titleFontFamily,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              offset: const Offset(1, 1),
                              blurRadius: 2,
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              offset: Offset.zero,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(height: 52, text: 'Profil'),
                          Tab(height: 52, text: 'Ayarlar'),
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
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/buttons/paper.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'İsim Değiştir',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 20,
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Oyuncu adı',
                  hintStyle: TextStyle(
                    fontFamily: AppTheme.titleFontFamily,
                    color: AppColors.parchmentTextSecondary.withValues(alpha: 0.6),
                  ),
                  counterStyle: TextStyle(
                    fontFamily: AppTheme.titleFontFamily,
                    color: AppColors.parchmentTextSecondary,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.parchmentBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.parchmentBorder),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.parchmentTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final newName = controller.text.trim();
                      if (newName.isNotEmpty) {
                        ref.read(careersProvider.notifier).updatePlayerName(newName);
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      'Kaydet',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.fieldGreenDark,
                        fontWeight: FontWeight.w800,
                      ),
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
            Text(
              'Aktif kariyer yok',
              style: TextStyle(
                fontFamily: AppTheme.titleFontFamily,
                color: AppColors.textHint,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final completedLevels = progress.levels.values.where((lp) => lp.completed);
    final matchesPlayed = completedLevels.length;
    final wins =
        completedLevels.where((lp) => lp.matchPoints == 3).length;
    final draws =
        completedLevels.where((lp) => lp.matchPoints == 1).length;
    final losses =
        completedLevels.where((lp) => lp.matchPoints == 0).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Takım bilgileri — maç, galibiyet, beraberlik, mağlubiyet, puan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/buttons/paper.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      'Takım Bilgileri',
                      style: TextStyle(
                      fontFamily: AppTheme.titleFontFamily,
                      color: AppColors.parchmentText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    ),
                  ),
                ),
                _ProfileStatRow(label: 'Oynanan Maç', value: '$matchesPlayed'),
                const _ProfilePaperDivider(),
                _ProfileStatRow(label: 'Galibiyet', value: '$wins'),
                const _ProfilePaperDivider(),
                _ProfileStatRow(label: 'Beraberlik', value: '$draws'),
                const _ProfilePaperDivider(),
                _ProfileStatRow(label: 'Mağlubiyet', value: '$losses'),
                const _ProfilePaperDivider(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _ProfileStatRow(
                    label: 'Puan',
                    value: '${progress.totalPoints}',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Kariyeri sıfırla — Çıkış butonu ile aynı asset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _RedAssetButton(
                label: 'Kariyeri Sıfırla',
                onTap: () => _showResetDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Kullanıcı kimliği — Profil tabında
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/buttons/paper.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 16,
                  color: AppColors.parchmentTextSecondary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Kullanıcı ID: ${career!.id}',
                    style: TextStyle(
                      fontFamily: AppTheme.titleFontFamily,
                      color: AppColors.parchmentText,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: career!.id),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Kopyalandı'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    size: 18,
                    color: AppColors.parchmentText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/buttons/paper.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kariyeri Sıfırla',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tüm kariyer verisi silinecek. Bu işlem geri alınamaz!',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentTextSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.parchmentTextSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final localStorage = ref.read(localStorageProvider);
                      await localStorage.clearAll();
                      ref.invalidate(careersProvider);
                      ref.invalidate(activeCareerProvider);
                      ref.invalidate(progressProvider);
                      ref.invalidate(livesProvider);
                      ref.invalidate(coinBalanceProvider);
                      ref.invalidate(activeCosmeticsProvider);
                      ref.invalidate(settingsProvider);
                      if (context.mounted) {
                        context.go('/career/setup');
                      }
                    },
                    child: Text(
                      'Sıfırla',
                      style: TextStyle(
                        fontFamily: AppTheme.titleFontFamily,
                        color: AppColors.error,
                        fontWeight: FontWeight.w800,
                      ),
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

void _showTeamChangeDialog(
  BuildContext context,
  WidgetRef ref,
  Career? career,
) {
  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/buttons/paper.png'),
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Takım Değiştir',
                style: TextStyle(
                  fontFamily: AppTheme.titleFontFamily,
                  color: AppColors.parchmentText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.0,
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
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Color(t.primaryColor).withValues(alpha: 0.2)
                            : AppColors.parchmentFillDark,
                        border: Border.all(
                          color: isSelected
                              ? Color(t.primaryColor)
                              : AppColors.parchmentBorder.withValues(alpha: 0.5),
                          width: isSelected ? 2 : 1,
                        ),
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
                                style: TextStyle(
                                  fontFamily: AppTheme.titleFontFamily,
                                  fontSize: 24,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Ana sayfadaki level zorluk/puan divider ile aynı stilde.
class _ProfilePaperDivider extends StatelessWidget {
  const _ProfilePaperDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.parchmentBorder.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

/// Profil sekmesinde takım istatistik satırı.
class _ProfileStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.titleFontFamily,
              color: AppColors.parchmentTextSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTheme.titleFontFamily,
              color: AppColors.parchmentText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Ayarlar Tab
// ══════════════════════════════════════════════════════════════
/// Çıkış butonu ile aynı asset (red_button.png).
class _RedAssetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RedAssetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/buttons/red_button.png'),
              fit: BoxFit.fill,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.titleFontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: context.tr('settings_language'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const _ProfilePaperDivider(),
              _ToggleRow(
                icon: Icons.volume_up,
                label: context.tr('settings_sound'),
                value: settings.soundEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleSound(v),
              ),
              const _ProfilePaperDivider(),
              _ToggleRow(
                icon: Icons.vibration,
                label: context.tr('settings_haptics'),
                value: settings.hapticsEnabled,
                onChanged: (v) =>
                    ref.read(settingsProvider.notifier).toggleHaptics(v),
              ),
              const _ProfilePaperDivider(),
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
          title: 'Destek & Yasal',
          child: Column(
            children: [
              _ActionRow(
                icon: Icons.star_rate_outlined,
                label: 'Bizi Değerlendir',
                onTap: () {
                  // TODO: Store review açılacak
                },
              ),
              const _ProfilePaperDivider(),
              _ActionRow(
                icon: Icons.help_outline,
                label: 'Yardım',
                onTap: () {
                  // TODO: Yardım sayfası
                },
              ),
              const _ProfilePaperDivider(),
              _ActionRow(
                icon: Icons.privacy_tip,
                label: 'Gizlilik Politikası',
                onTap: () {
                  // TODO: URL launcher ile açılacak
                },
              ),
              const _ProfilePaperDivider(),
              _ActionRow(
                icon: Icons.description,
                label: 'Kullanım Koşulları',
                onTap: () {
                  // TODO: URL launcher ile açılacak
                },
              ),
              const _ProfilePaperDivider(),
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
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/buttons/paper.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${context.tr('settings_version')}: ${AppConfig.appVersion}',
              style: TextStyle(
                fontFamily: AppTheme.titleFontFamily,
                color: AppColors.parchmentText,
                fontSize: 12,
              ),
            ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/buttons/paper.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTheme.titleFontFamily,
                      color: AppColors.parchmentText,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
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
          Icon(icon, color: AppColors.parchmentTextSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.titleFontFamily,
                color: AppColors.parchmentText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.fieldGreenDark,
            inactiveTrackColor: AppColors.parchmentFillDark,
            activeThumbColor: AppColors.ball,
            inactiveThumbColor: AppColors.parchmentText,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.parchmentTextSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.titleFontFamily,
          color: AppColors.parchmentText,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.parchmentTextSecondary,
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
              ? AppColors.parchmentFillDark
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.parchmentBorder
                : AppColors.parchmentBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.titleFontFamily,
            color: isSelected
                ? AppColors.parchmentText
                : AppColors.parchmentTextSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
