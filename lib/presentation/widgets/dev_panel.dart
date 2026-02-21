// ═══════════════════════════════════════════════════════════════════
// DEBUG PANEL — Sadece kDebugMode=true olduğunda görünür
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_career_football_puzzle/presentation/providers/app_providers.dart';

class DevPanel extends ConsumerWidget {
  final int totalLevels;
  const DevPanel({super.key, required this.totalLevels});

  static Widget maybeShow({required int totalLevels}) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Positioned(
      right: 12,
      bottom: 120,
      child: DevPanel(totalLevels: totalLevels),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.small(
      heroTag: 'dev_panel_fab',
      backgroundColor: Colors.black87,
      onPressed: () => _showDevSheet(context, ref),
      tooltip: 'Dev Panel',
      child: const Text('🛠️', style: TextStyle(fontSize: 16)),
    );
  }

  void _showDevSheet(BuildContext context, WidgetRef ref) {
    final levelCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Başlık ─────────────────────────────────────────
            Row(
              children: [
                const Text(
                  '🛠️  Developer Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'DEBUG',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Can doldur ─────────────────────────────────────
            _DevActionRow(
              icon: '❤️',
              label: 'Canları Doldur (Max 10)',
              subtitle: 'Can sayısını maksimuma yükseltir',
              onTap: () async {
                await ref.read(livesProvider.notifier).fillLives();
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❤️ Canlar dolduruldu!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // ── Level atla ─────────────────────────────────────
            const Text(
              '🎮  İstediğin Levele Atla',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: levelCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: '1 – $totalLevels',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final n = int.tryParse(levelCtrl.text.trim());
                    if (n == null || n < 1 || n > totalLevels) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '⚠️ 1 ile $totalLevels arasında girin',
                            ),
                            backgroundColor: const Color(0xFFF44336),
                          ),
                        );
                      }
                      return;
                    }
                    await ref.read(progressProvider.notifier).jumpToLevel(n);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Level $n\'e atlandı!'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Git',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DevActionRow extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DevActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
