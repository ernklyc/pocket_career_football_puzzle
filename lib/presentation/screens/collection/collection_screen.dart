import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_colors.dart';
import 'package:pocket_career_football_puzzle/core/theme/app_theme.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/app_bar_parchment.dart';
import 'package:pocket_career_football_puzzle/presentation/widgets/under_maintenance_widget.dart';

/// Koleksiyon ekranı — Kupa Sergim, Bloklarım, Başarımlarım (hepsi tek sayfada).
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/league/1.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const AppBarParchment(title: 'Koleksiyon'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Kupa Sergim
                      _SectionCard(
                        icon: Icons.emoji_events,
                        title: 'Kupa Sergim',
                        iconColor: AppColors.parchmentText,
                        child: const UnderMaintenanceWidget(fullPage: false),
                      ),
                      const SizedBox(height: 16),

                      // 2. Bloklarım
                      _SectionCard(
                        icon: Icons.extension,
                        title: 'Bloklarım',
                        iconColor: AppColors.parchmentText,
                        child: const UnderMaintenanceWidget(fullPage: false),
                      ),
                      const SizedBox(height: 16),

                      // 3. Başarımlarım
                      _SectionCard(
                        icon: Icons.military_tech,
                        title: 'Başarımlarım',
                        iconColor: AppColors.parchmentText,
                        child: const UnderMaintenanceWidget(fullPage: false),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTheme.titleFontFamily,
                    color: AppColors.parchmentText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: child,
          ),
        ],
      ),
    );
  }
}
