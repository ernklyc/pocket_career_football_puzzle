import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/core/config/app_config.dart';
import 'package:pocket_career_football_puzzle/core/localization/l10n.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

/// Ayarlar ekranı.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isSignedIn = ref.watch(authProvider) != null;
    final isPremium = ref.watch(entitlementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('settings_title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/game/main');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dil
          _SettingsSection(
            title: context.tr('settings_language'),
            child: Row(
              children: [
                _LanguageChip(
                  label: 'Türkçe',
                  isSelected: settings.language == 'tr',
                  onTap: () => ref.read(settingsProvider.notifier).updateLanguage('tr'),
                ),
                const SizedBox(width: 8),
                _LanguageChip(
                  label: 'English',
                  isSelected: settings.language == 'en',
                  onTap: () => ref.read(settingsProvider.notifier).updateLanguage('en'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ses & Titreşim
          _SettingsSection(
            title: 'Ses & Titreşim',
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.music_note,
                  label: context.tr('settings_music'),
                  value: settings.musicEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleMusic(v),
                ),
                _ToggleRow(
                  icon: Icons.volume_up,
                  label: context.tr('settings_sound'),
                  value: settings.soundEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleSound(v),
                ),
                _ToggleRow(
                  icon: Icons.vibration,
                  label: context.tr('settings_haptics'),
                  value: settings.hapticsEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleHaptics(v),
                ),
                _ToggleRow(
                  icon: Icons.notifications,
                  label: context.tr('settings_notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleNotifications(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hesap
          _SettingsSection(
            title: 'Hesap',
            child: Column(
              children: [
                if (isSignedIn)
                  _ActionRow(
                    icon: Icons.logout,
                    label: context.tr('settings_sign_out'),
                    color: AppColors.error,
                    onTap: () async {
                      await ref.read(authServiceProvider).signOut();
                      ref.read(authProvider.notifier).state = null;
                    },
                  )
                else
                  _ActionRow(
                    icon: Icons.login,
                    label: context.tr('settings_sign_in'),
                    color: AppColors.info,
                    onTap: () async {
                      final user = await ref.read(authServiceProvider).signInWithGoogle();
                      ref.read(authProvider.notifier).state = user;
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Satın Alma
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
                  icon: Icons.restore,
                  label: context.tr('settings_restore_purchases'),
                  onTap: () async {
                    final purchases = ref.read(purchasesServiceProvider);
                    final success = await purchases.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Satın alımlar geri yüklendi' : 'Geri yükleme başarısız'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Yasal
          _SettingsSection(
            title: 'Yasal',
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.privacy_tip,
                  label: context.tr('settings_privacy_policy'),
                  onTap: () {
                    // TODO: URL aç
                  },
                ),
                _ActionRow(
                  icon: Icons.description,
                  label: context.tr('settings_terms'),
                  onTap: () {
                    // TODO: URL aç
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sürüm
          Center(
            child: Text(
              '${context.tr('settings_version')}: ${AppConfig.appVersion}',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

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
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppColors.parchmentTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
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
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppColors.textPrimary,
              ),
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
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: color ?? AppColors.textPrimary,
        ),
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
